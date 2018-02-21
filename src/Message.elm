module Message exposing (..)

import Http

import Model exposing (TrackingId)

type Msg =
    XmlResponse TrackingId (Result Http.Error String)
    | LoadTrackingInformation (List TrackingId)

