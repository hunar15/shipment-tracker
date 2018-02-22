module Model exposing (..)

import Date exposing (Date)

type alias StatusMessage = String

type alias Status =
    { dateTime : Date
    , statusMessage : StatusMessage
    , location : Maybe String
    }


type alias Order = { trackingId : String
                   , statusList : List Status
                   }

type alias Model = { activeOrders : List Order
                   , trackingIdInNewForm : TrackingId
                   }

type alias TrackingId = String
