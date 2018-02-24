module OrderForm.Model exposing (..)

type alias Model =
    { trackingId: String }

emptyForm : Model
emptyForm =
    { trackingId = "" }
