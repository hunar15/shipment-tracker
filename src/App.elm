module Main exposing (..)

import Html exposing (div, button, text, Html)
import Debug
import Http

import Models.Types as Bpost

main =
  Html.program { subscriptions = subscriptions
               , view = view
               , update = update
               , init = init }

type alias Model =
    { statusList : List Bpost.Status }

init : (Model, Cmd Msg)
init = ( { statusList = [] }
       , getXmlResponse
       )

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

getXmlResponse : Cmd Msg
getXmlResponse =
    let
        trackingUrl = getBpostURL "312014853400000769000219190151"
    in
        Http.send XmlResponse (Http.getString trackingUrl)

view : Model -> Html Msg
view model =
  let
      statusToDiv : Bpost.Status -> Html Msg
      statusToDiv (Bpost.Status status) =
          case status.statusMessage of
              Bpost.StatusMessage messageString ->
                  div [] [ text messageString ]
  in
      div [] (List.map statusToDiv model.statusList)


type Msg = XmlResponse (Result Http.Error String)

 -- TODO organize into different folders

getBpostURL : String -> String
getBpostURL trackCode =
    "http://www.bpost2.be/bpostinternational/track_trace/find.php?search=s&lng=en&trackcode=" ++ trackCode

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    XmlResponse (Ok data) ->
        let
            parseResult = Bpost.parseHttpResponse data
        in
            case parseResult of
                Ok parsedList ->
                    ({ model | statusList = parsedList }, Cmd.none)
                Err _ ->
                    (model, Cmd.none)

    XmlResponse (Err _) ->
            (model, Cmd.none)
