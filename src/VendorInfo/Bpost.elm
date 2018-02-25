module VendorInfo.Bpost exposing (..)

import Date exposing (Date)

import Xml.Decode as XD
import Xml.Decode.Extra exposing (..)
import DateParser
import Date.Extra.Config.Config_en_us as DateConfig

import CommonModel exposing (..)

fromString : String -> Result String Date
fromString dateString =
    DateParser.parse DateConfig.config "%d-%m-%Y %H:%M:%S" dateString
                |> (Result.mapError toString)

dateDecoder : XD.Decoder Date
dateDecoder =
    let
        resultToDecoder : Result String Date -> XD.Decoder Date
        resultToDecoder dateResult =
            case dateResult of
                Ok date -> XD.succeed date
                Err errorString -> XD.fail (XD.SimpleError (XD.Unparsable errorString))

    in
        XD.string
            |> XD.map fromString
            |> XD.andThen resultToDecoder

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
            XD.path ["dateTime"] (XD.single dateDecoder)

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
