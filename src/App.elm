module Main exposing (..)

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

type Msg = XmlResponse TrackingId (Result Http.Error String)

init : (Model, Cmd Msg)
init =
    let
        initialOrders = createInitOrders
    in
        ( initialOrders
        , fetchDataForOrders initialOrders
        )

createInitOrders : List Order
createInitOrders =
    let
        trackingIds =
            [ "312014853400000769000219190151"
            , "312014853400000769000216070185"
            ]

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

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

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
               --     ({ model | statusList = parsedList }, Cmd.none)
                    (model, Cmd.none)
                (_, _, Err _) ->
                    (model, Cmd.none)

    XmlResponse _ (Err _) ->
            (model, Cmd.none)
