import Html exposing (div, button, text, Html)
import Debug
import Http
import Xml.Decode exposing (decode)

main =
  Html.program { subscriptions = subscriptions
               , view = view
               , update = update
               , init = init }

type alias Model =
    { responseData : String }

init : (Model, Cmd Msg)
init = ( { responseData = "" }
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
  div []
    [ div [] [ text model.responseData ]
    ]


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
            loggedData = Debug.log "Data" data
        in
            ({ model | responseData = loggedData |> toString }, Cmd.none)

    XmlResponse (Err _) ->
            ({ model | responseData = "Error encountered"}, Cmd.none)
