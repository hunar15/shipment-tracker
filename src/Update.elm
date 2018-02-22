module Update exposing (update)

import Debug exposing (log)
import Http

import Message exposing (Msg(..))
import Model exposing (Model)
import Decoders
import Utilities

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    XmlResponse trackingId (Ok data) ->
        let
            parseResult = Decoders.parseHttpResponse data
            loggedData = log "data" data
            loggedId = log "trackingId" trackingId

        in
            case (loggedData, loggedId, parseResult) of
                (_, _,Ok parsedList) ->
                    ({ model
                         | activeOrders =
                             Utilities.updateOrder
                                 model.activeOrders
                                 { trackingId = trackingId
                                 , statusList = parsedList
                                 }}
                    , Cmd.none)
                (_, _, Err error) ->
                    log error
                    (model, Cmd.none)

    XmlResponse _ (Err _) ->
            (model, Cmd.none)

    LoadTrackingInformation trackingIds ->
         let
             initialOrders = Utilities.createInitOrders trackingIds
         in
             ({ model | activeOrders = initialOrders }
             , fetchDataForOrders initialOrders
             )

    TrackingIdChanged newTrackingId ->
        ({model | trackingIdInNewForm = newTrackingId }, Cmd.none)

    CreateNewTrackingOrder trackingId ->
        let
            newOrder = Utilities.createNewOrder trackingId
        in
            ({ model
                 | activeOrders = model.activeOrders ++ [newOrder]
             }
            , fetchDataForOrders [newOrder])


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
