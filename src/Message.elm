module Message exposing (..)

import Http

import Model exposing (TrackingId)

import OrderForm.Message

type Msg =
    XmlResponse TrackingId (Result Http.Error String)
    | LoadTrackingInformation (List TrackingId)
    | FormMessage OrderForm.Message.Msg
    | CreateOrder TrackingId
    | DeleteOrder TrackingId
