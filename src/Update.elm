port module Update exposing (update)

import Http
import Task
import Time
import Debug exposing (log)
import Json.Encode as Json

import Message exposing (Msg(..))
import Model exposing (Model)
import CommonModel
import OrderForm.Update as FormUpdate
import OrderForm.Message as FormMessage
import VendorInfo.Aftership as Aftership
import Utilities

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    XmlResponse vendorInfo trackingId (Ok data) ->
        let
            parseResult = vendorInfo.responseDecoder data
        in
            case parseResult of
                Ok parsedList ->
                    ({ model
                         | activeOrders =
                             Utilities.updateOrder
                                 model.activeOrders
                                 { trackingId = trackingId
                                 , vendor = vendorInfo
                                 , statusList = parsedList
                                 }}
                    , Cmd.none)
                Err error ->
                    (model, Cmd.none)

    XmlResponse _ _ (Err _) ->
            (model, Cmd.none)

    LoadTrackingInformation storedOrders ->
         let
             jsonParseResult = Utilities.createInitOrders storedOrders
         in
             case jsonParseResult of
                 Ok initialOrders ->
                     ({ model | activeOrders = initialOrders }
                     , fetchDataForOrders initialOrders
                     )
                 Err errorString ->
                     (model, Cmd.none)

    FormMessage submsg ->
        let
            updateFormModel : Model -> Model
            updateFormModel m =
                { m | formModel = FormUpdate.update submsg model.formModel }

            updateActiveOrders : Model -> (Model, Cmd Msg)
            updateActiveOrders m =
                case submsg of
                    FormMessage.SubmitForm vendor trackingId ->
                        (m, Task.perform (\_ -> CreateOrder vendor trackingId) Time.now)
                    _ ->
                        (m, Cmd.none)

        in
            model
                |> updateFormModel
                |> updateActiveOrders

    CreateOrder vendor trackingId ->
        let
            newOrder : CommonModel.Order
            newOrder = Utilities.createNewOrder trackingId vendor

            updatedOrders = model.activeOrders ++ [newOrder]
        in
            ({ model | activeOrders = updatedOrders }
            , Cmd.batch [ fetchDataForOrders [newOrder]
                        , updateStorage (List.map Utilities.createPersistableOrder updatedOrders)]
            )

    DeleteOrder trackingId ->
        let
            deleteByTrackingId : List CommonModel.Order -> CommonModel.TrackingId -> List CommonModel.Order
            deleteByTrackingId orders trackingIdToDelete =
                List.filter (\order -> order.trackingId /= trackingIdToDelete) orders

            updatedOrders = deleteByTrackingId model.activeOrders trackingId
        in
            ({ model | activeOrders = updatedOrders }
            , updateStorage (List.map Utilities.createPersistableOrder updatedOrders))

    DeleteAftershipOrder trackingId ->
        let
            responseHandler : Result Http.Error Json.Value -> Msg
            responseHandler result =
                case result of
                    Ok _ ->
                        FetchAftershipOrders
                    Err httpError ->
                        ShowError ("error encountered while deleting orders" ++ (toString httpError))

        in
            ( model
            , Http.send
                responseHandler
                (Utilities.deleteAftershipOrderRequest model.aftershipApiKey trackingId)
            )

    FetchAftershipOrders ->
        let
            responseHandler : Result Http.Error Json.Value -> Msg
            responseHandler result =
                case result of
                    Ok responseString -> LoadAftershipOrders responseString
                    Err httpError ->
                        ShowError ("error encountered while fetching orders" ++ (toString httpError))
        in
            ( model
            , Http.send
                 responseHandler
                 (Utilities.httpRequestForAftershipOrders model.aftershipApiKey)
            )

    LoadAftershipOrders jsonResponse ->
        let
            parseResult = Aftership.parseJson jsonResponse
        in
            case parseResult of
                Ok parsedOrders ->
                    ({ model | aftershipOrders = parsedOrders }
                    , Cmd.none
                    )
                Err parseErrorMessage ->
                    ( model
                    , Task.perform (\_ -> ShowError parseErrorMessage) Time.now
                    )

    ShowError errorMessage ->
        let
            loggedMessage = log "error message : " errorMessage
        in
            ({ model | errorMessage = loggedMessage }
            , Cmd.none
            )

port updateStorage : List Json.Value -> Cmd msg

fetchDataForOrders : List CommonModel.Order -> Cmd Msg
fetchDataForOrders orders =
    let
        createTrackingUrl : String -> String
        createTrackingUrl trackingId =
            "http://www.bpost2.be/bpostinternational/track_trace/find.php?search=s&lng=en&trackcode=" ++ trackingId

        createCmdForOrder : CommonModel.Order -> Cmd Msg
        createCmdForOrder order =
            Http.send
                (XmlResponse order.vendor order.trackingId)
                (Http.getString (createTrackingUrl order.trackingId))

        listOfCmds : List CommonModel.Order -> List (Cmd Msg)
        listOfCmds orders =
            List.map createCmdForOrder orders
    in
        Cmd.batch (listOfCmds orders)
