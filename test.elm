import Html exposing (beginnerProgram, div, button, text, Html)
import Html.Events exposing (onClick)
import Debug
import Http

main =
  Html.program { subscriptions = subscriptions
               , view = view
               , update = update
               , init = init }

type alias Model =
    { counter : Int
    , responseData : String
    }

init : (Model, Cmd Msg)
init = ( { counter = 0, responseData = "" }
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
    [ button [ onClick Decrement ] [ text "-" ]
    , div [] [ text (toString model.counter) ]
    , button [ onClick Increment ] [ text "+" ]
    ]


type Msg = Increment
         | Decrement
         | XmlResponse (Result Http.Error String)

 -- TODO organize into different folders

getBpostURL : String -> String
getBpostURL trackCode =
    "http://www.bpost2.be/bpostinternational/track_trace/find.php?search=s&lng=en&trackcode=" ++ trackCode

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Increment ->
      ({ model | counter = model.counter + 1}, Cmd.none)

    Decrement ->
      ({ model | counter = model.counter - 1 }, Cmd.none)

    XmlResponse (Ok data) ->
        let
            loggedData = Debug.log "Data" data
        in
            ({ model | responseData = loggedData }, Cmd.none)

    XmlResponse (Err _) ->
            ({ model | responseData = "Error encountered"}, Cmd.none)
