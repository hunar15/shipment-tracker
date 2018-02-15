import Html exposing (beginnerProgram, div, button, text, Html)
import Html.Events exposing (onClick)

main =
  beginnerProgram { model = model, view = view, update = update }

type alias  Model = Int


model : Model
model = 0

view : model -> Html Msg
view model =
  div []
    [ button [ onClick Decrement ] [ text "-" ]
    , div [] [ text (toString model) ]
    , button [ onClick Increment ] [ text "+" ]
    ]


type Msg = Increment | Decrement


update : Msg -> Model -> Model
update msg model =
  case msg of
    Increment ->
      model + 1

    Decrement ->
      model - 1
