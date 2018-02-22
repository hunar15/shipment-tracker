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


createNewOrder : TrackingId -> Model.Order
createNewOrder trackingId =
    { trackingId = trackingId
    , statusList = []
    }
