module Message exposing (..)

import Http
import Json.Encode as Json

import CommonModel exposing (..)
import OrderForm.Message

type Msg =
    XmlResponse Vendor TrackingId (Result Http.Error String)
    | LoadTrackingInformation Json.Value
    | FormMessage OrderForm.Message.Msg
    | CreateOrder Vendor TrackingId
    | DeleteOrder TrackingId
