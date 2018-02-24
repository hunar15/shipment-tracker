module OrderForm.Update exposing (update)

import OrderForm.Message exposing (Msg(..))
import OrderForm.Model exposing (Model)


update : Msg -> Model -> Model
update msg model =
    case msg of
        TrackingIdChanged newTrackingId ->
            { model | trackingId = newTrackingId }

        SubmitForm _ ->
            OrderForm.Model.emptyForm
