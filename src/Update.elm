module Update exposing (update)

import Http
import Task
import Time

import Message exposing (Msg(..))
import Model exposing (Model)
import OrderForm.Update as FormUpdate
import OrderForm.Message as FormMessage
import Decoders
import Utilities

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    XmlResponse trackingId (Ok data) ->
        let
            parseResult = Decoders.parseHttpResponse data
        in
            case parseResult of
                Ok parsedList ->
                    ({ model
                         | activeOrders =
                             Utilities.updateOrder
                                 model.activeOrders
                                 { trackingId = trackingId
                                 , statusList = parsedList
                                 }}
                    , Cmd.none)
                Err error ->
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

    FormMessage submsg ->
        let
            updateFormModel : Model -> Model
            updateFormModel m =
                { m | formModel = FormUpdate.update submsg model.formModel }

            updateActiveOrders : Model -> (Model, Cmd Msg)
            updateActiveOrders m =
                case submsg of
                    FormMessage.SubmitForm trackingId ->
                        (m, Task.perform (\_ -> CreateOrder trackingId) Time.now)
                    _ ->
                        (m, Cmd.none)

        in
            model
                |> updateFormModel
                |> updateActiveOrders

    CreateOrder trackingId ->
        let
            newOrder = Utilities.createNewOrder trackingId
        in
            ({ model | activeOrders = model.activeOrders ++ [newOrder] }
            , fetchDataForOrders [newOrder]
            )




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
