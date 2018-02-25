module OrderForm.Model exposing (..)

import CommonModel exposing (Vendor)

type alias Model =
    { trackingId: String
    , selectedVendor : Maybe Vendor
    }

emptyForm : Model
emptyForm =
    { trackingId = ""
    , selectedVendor = Nothing
    }
