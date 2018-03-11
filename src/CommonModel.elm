module CommonModel exposing (..)

import Date exposing (Date)

type alias TrackingId = String
type alias ApiResponse = String
type alias StatusMessage = String

type alias Order =
    { trackingId : String
    , vendor : Vendor
    , statusList : List Status
    }

type alias AftershipOrder =
    { trackingId : String
    , trackingNumber: String
    , slugId : String
    , statusList : List Status
    }

type alias Status =
    { dateTime : Date
    , statusMessage : StatusMessage
    , location : Maybe String
    }

type alias Vendor =
    { name : String
    , id : String
    , endpointMaker : TrackingId -> String
    , responseDecoder : ApiResponse -> Result String (List Status)
    }
