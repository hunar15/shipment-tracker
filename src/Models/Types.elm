module Models.Types exposing (..)

import Xml.Decode as XD
import Xml.Decode.Extra exposing (..)
import Date exposing (Date)

type StatusMessage = StatusMessage String

type Status =
    Status { dateTime : Date
           , statusMessage : StatusMessage
           , location : Maybe String
           }


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

        dateTimeDecoder : XD.Decoder Date
        dateTimeDecoder =
            XD.path ["dateTime"] (XD.single XD.date)

        statusDecoder : XD.Decoder StatusMessage
        statusDecoder =
            XD.path ["status"] (XD.single statusMessageDecoder)

        lambda : Date -> StatusMessage -> (Maybe String) -> Status
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

parseHttpResponse : String -> Result String (List Status)
parseHttpResponse responseText =
    let
        statusListDecoder : XD.Decoder (List Status)
        statusListDecoder =
            XD.path ["parcel", "deliveryStatus", "status"] (XD.list statusDecoder)
    in
        XD.run statusListDecoder responseText
