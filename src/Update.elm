module Update exposing (update)

import Debug exposing (log)

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
                    (Utilities.updateOrder
                         model
                         { trackingId = trackingId
                         , statusList = parsedList
                         }, Cmd.none)
                (_, _, Err error) ->
                    log error
                    (model, Cmd.none)

    XmlResponse _ (Err _) ->
            (model, Cmd.none)

    LoadTrackingInformation trackingIds ->
         let
             initialOrders = Utilities.createInitOrders trackingIds
         in
             ( initialOrders
             , Utilities.fetchDataForOrders initialOrders
             )

