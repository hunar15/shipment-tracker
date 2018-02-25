module OrderForm.Update exposing (update)

import OrderForm.Message exposing (Msg(..))
import OrderForm.Model exposing (Model)


update : Msg -> Model -> Model
update msg model =
    case msg of
        TrackingIdChanged newTrackingId ->
            { model | trackingId = newTrackingId }

        VendorChanged vendor ->
            { model | selectedVendor = vendor }
        SubmitForm _ _ ->
            OrderForm.Model.emptyForm
