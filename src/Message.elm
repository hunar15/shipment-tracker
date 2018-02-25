module Message exposing (..)

import Http

import CommonModel exposing (..)

import OrderForm.Message

type Msg =
    XmlResponse Vendor TrackingId (Result Http.Error String)
    | LoadTrackingInformation (List TrackingId)
    | FormMessage OrderForm.Message.Msg
    | CreateOrder Vendor TrackingId
    | DeleteOrder TrackingId
