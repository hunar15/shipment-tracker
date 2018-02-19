module Models.Types exposing (..)

import Xml.Decode as XD
import Xml.Decode.Extra exposing (..)
import Date exposing (Date)

type alias StatusMessage = String

type alias Status =
    { dateTime : Date
    , statusMessage : StatusMessage
    , location : Maybe String
    }


statusMessageDecoder : XD.Decoder StatusMessage
statusMessageDecoder =
    XD.path ["en"] (XD.single XD.string)

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
            { dateTime = dateTime
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

mostRecentStatus : List Status -> Maybe Status
mostRecentStatus _ =
    -- TODO: implement this
    Nothing


