port module Main exposing (..)

import Html exposing (ul, li, button, text, Html, h5, div, small)
import Html.Attributes exposing (class, classList)
import Debug exposing (log)
import Http

import Models.Types as Bpost

main =
  Html.program { subscriptions = subscriptions
               , view = view
               , update = update
               , init = init }

type alias Order = { trackingId : String
                   , statusList : List Bpost.Status
                   }

type alias Model = List Order

type alias TrackingId = String

type Msg =
    XmlResponse TrackingId (Result Http.Error String)
    | LoadTrackingInformation (List TrackingId)

init : (Model, Cmd Msg)
init = ([], Cmd.none)

createInitOrders : List TrackingId ->  List Order
createInitOrders trackingIds =
    let
        createOrderForTrackingId : String -> Order
        createOrderForTrackingId id =
            { trackingId = id
            , statusList = []
            }
    in
        List.map createOrderForTrackingId trackingIds

fetchDataForOrders : List Order -> Cmd Msg
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

        trackingIds : List Order -> List String
        trackingIds orders =
            List.map .trackingId orders

        listOfCmds : List Order -> List (Cmd Msg)
        listOfCmds orders =
            List.map createCmdForTrackingId (trackingIds orders)
    in
        Cmd.batch (listOfCmds orders)

--- SUBSCRIPTIONS ---

port loadTrackingIds : (List TrackingId -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  loadTrackingIds LoadTrackingInformation

view : Model -> Html Msg
view model =
  let
      createRow : Order -> Html Msg
      createRow order =
          li [ class "list-group-item" ]
             [ div [ class "row" ]
                   [ div [ class "col-6" ]
                         [ small []
                                 [ text order.trackingId ]
                         ]
                   , div [ class "col-6" ]
                         [ text ((Maybe.withDefault "no message available")
                                     (Maybe.map .statusMessage (Bpost.mostRecentStatus order.statusList))
                                )
                         ]
                   ]
             ]
  in
      div [ classList [ ("panel", True)
                      , ("panel-default", True)]
          ]
          [ ul [ class "list-group" ]
                (List.map createRow model)
          ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    XmlResponse trackingId (Ok data) ->
        let
            parseResult = Bpost.parseHttpResponse data
            loggedData = log "data" data
            loggedId = log "trackingId" trackingId

        in
            case (loggedData, loggedId, parseResult) of
                (_, _,Ok parsedList) ->
                    (updateOrder
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
             initialOrders = createInitOrders trackingIds
         in
             ( initialOrders
             , fetchDataForOrders initialOrders
             )

updateOrder : List Order -> Order -> List Order
updateOrder orderList newOrder =
    let
        updater : Order -> Order
        updater oldOrder =
            if oldOrder.trackingId == newOrder.trackingId then
                newOrder
            else
                oldOrder

    in
        List.map updater orderList
