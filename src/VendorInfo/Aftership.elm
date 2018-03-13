module VendorInfo.Aftership exposing (..)

import Json.Encode as Json
import Json.Decode exposing ( Decoder
                            , at
                            , map
                            , map3
                            , map4
                            , decodeValue
                            , list
                            , fail
                            , string
                            , succeed
                            , andThen
                            , nullable
                            )
import Date exposing ( Date )

import DateParser exposing ( parse )
import Date.Extra.Config.Config_en_us as DateConfig

import CommonModel exposing ( Status
                            , AftershipOrder
                            )



dateTimeDecoder : Decoder Date
dateTimeDecoder =
    let
        strToDate : String -> Result String Date
        strToDate dateString =
            dateString
                |> parse DateConfig.config "%Y-%m-%dT%H:%M:%S"
                |> Result.mapError toString

        resultToDecoder : Result String Date -> Decoder Date
        resultToDecoder dateResult =
            case dateResult of
                Ok date -> succeed date
                Err errorString -> fail errorString
    in
        string
            |> andThen
               (\str ->
                    str
                        |> strToDate
                        |> resultToDecoder
               )


statusDecoder : Decoder Status
statusDecoder =
    let
        assembler : Date -> String -> Maybe String -> Status
        assembler date message location =
            { dateTime = date
            , statusMessage = message
            , location = location
            }
    in
        map3
            assembler
            (at ["checkpoint_time"] dateTimeDecoder)
            (at ["message"] string)
            (at ["country_name"] (nullable string))

trackingDecoder : Decoder AftershipOrder
trackingDecoder =
    let
        assembler : (List Status) -> String -> String -> String -> AftershipOrder
        assembler statusList trackingId trackingNumber slug =
            { trackingId = trackingId
            , trackingNumber = trackingNumber
            , slugId = slug
            , statusList = statusList
            }
    in
        map4
            assembler
            (at ["checkpoints"] (list statusDecoder))
            (at ["id"] string)
            (at ["tracking_number"] string)
            (at ["slug"] string)

trackingListDecoder : Decoder (List AftershipOrder)
trackingListDecoder = list trackingDecoder

orderListDecoder : Decoder (List AftershipOrder)
orderListDecoder = at ["data", "trackings"] trackingListDecoder

parseJson : Json.Value -> Result String (List AftershipOrder)
parseJson json = decodeValue orderListDecoder json
