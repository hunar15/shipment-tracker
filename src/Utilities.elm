module Utilities exposing (..)

import Date exposing (Date)
import Http

import Model exposing (..)
import Message exposing (Msg(..))


createInitOrders : List TrackingId ->  List Model.Order
createInitOrders trackingIds =
    let
        createOrderForTrackingId : String -> Model.Order
        createOrderForTrackingId id =
            { trackingId = id
            , statusList = []
            }
    in
        List.map createOrderForTrackingId trackingIds

fetchDataForOrders : List Model.Order -> Cmd Msg
fetchDataForOrders orders =
    let
        createTrackingUrl : String -> String
        createTrackingUrl trackingId =
            "http://www.bpost2.be/bpostinternational/track_trace/find.php?search=s&lng=en&trackcode=" ++ trackingId

        createCmdForTrackingId : String -> Cmd Msg
        createCmdForTrackingId trackingId =
            Http.send
                (XmlResponse trackingId)
                (Http.getString (createTrackingUrl trackingId))

        trackingIds : List Model.Order -> List String
        trackingIds orders =
            List.map .trackingId orders

        listOfCmds : List Model.Order -> List (Cmd Msg)
        listOfCmds orders =
            List.map createCmdForTrackingId (trackingIds orders)
    in
        Cmd.batch (listOfCmds orders)


mostRecentStatus : List Status -> Maybe Status
mostRecentStatus statusList =
    let
        latestDateComparer status =
            status.dateTime
                |> Date.toTime
                |> negate

    in
        List.sortBy latestDateComparer statusList
            |> List.head


updateOrder : List Model.Order -> Model.Order -> List Model.Order
updateOrder orderList newOrder =
    let
        updater : Model.Order -> Model.Order
        updater oldOrder =
            if oldOrder.trackingId == newOrder.trackingId then
                newOrder
            else
                oldOrder

    in
        List.map updater orderList
