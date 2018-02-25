module OrderForm.Message exposing (..)

import CommonModel exposing (..)

type Msg =
     TrackingIdChanged TrackingId
     | VendorChanged (Maybe Vendor)
     | SubmitForm Vendor TrackingId
