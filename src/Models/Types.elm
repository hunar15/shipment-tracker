module Models.Types exposing (..)

import Xml.Decode as XD
import Xml.Decode.Extra exposing (..)

type StatusMessage = StatusMessage String

type Status =
    Status { dateTime : String
           , statusMessage : StatusMessage
           , location : Maybe String
           }


-- type Status = Status String

-- type DeliveryStatus =
--     DeliveryStatus
--     { statusList : List Status }

-- type Parcel =
--     Parcel
--     { trackingBarcode : String
--     , deliveryStatus : DeliveryStatus
--     }

-- type Parcels =
--     Parcels
--     { parcel : Parcel
--     }


statusMessageDecoder : XD.Decoder StatusMessage
statusMessageDecoder =
    let
        strExtractor : XD.Decoder String
        strExtractor = XD.path ["en"] (XD.single XD.string)
    in
        XD.map (\s -> StatusMessage s) strExtractor

statusDecoder : XD.Decoder Status
statusDecoder =
    let
        ---
        locationDecoder : XD.Decoder (Maybe String)
        locationDecoder =
            XD.path ["location"] (XD.single XD.string)
                |> XD.maybe

        dateTimeDecoder : XD.Decoder String
        dateTimeDecoder =
            XD.path ["dateTime"] (XD.single XD.string)

        statusDecoder : XD.Decoder StatusMessage
        statusDecoder =
            XD.path ["status"] (XD.single statusMessageDecoder)

        lambda : String -> StatusMessage -> (Maybe String) -> Status
        lambda dateTime status maybeLocation =
            Status { dateTime = dateTime
                   , statusMessage = status
                   , location = maybeLocation
                   }
    in
        XD.succeed (lambda)
            |: dateTimeDecoder
            |: statusDecoder
            |: locationDecoder
