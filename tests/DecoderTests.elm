module DecoderTests exposing (..)

import Date exposing (Date)

import Expect exposing (Expectation)
import Test exposing (..)


import Xml.Decode as XD exposing ( path
                           , single
                           , string )

import Decoders exposing (..)
import Model exposing (..)

suite : Test
suite =
    describe "Model.Types"
        [ describe "Bpost Response Decoders"
             [ test "can decode xml value into correct type" <|
                  \_ ->
                   let
                       xmlString =
                           """
                            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
                            <?xml-stylesheet type="text/xsl" href="tpl_2_en.xsl"?>
                           <status>
                            <location>Belgium</location>
                            <dateTime>07-02-2018 15:30:29</dateTime>
                            <status>
                            <en>Parcel is handled</en>
                            </status>
                            <statusCode>BI3</statusCode>
                           </status>
                           """

                       expectedDateResult : Result String Date
                       expectedDateResult = Decoders.fromString "07-02-2018 15:30:29"
                   in
                       case expectedDateResult of
                           Ok parsedDate ->
                               Expect.equal
                                   (XD.run Decoders.statusDecoder xmlString)
                                   (Ok { dateTime = parsedDate
                                       , statusMessage = "Parcel is handled"
                                       , location = Just "Belgium"
                                       })
                           Err _ ->
                               Expect.fail "Date should have been parseable"

             , test "can correctly decode english status text" <|
                 \_ ->
                     let
                         xmlString =
                             """
                             <status>
                              <en>Parcel is handled</en>
                             </status>
                             """
                     in
                         Expect.equal
                             (XD.run Decoders.statusMessageDecoder xmlString)
                             (Ok "Parcel is handled")

             , test "can extract list of statuses from http string response" <|
                 \_ ->
                     let
                         httpResponse =
                             """
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <?xml-stylesheet type="text/xsl" href="tpl_2_en.xsl"?>
    <parcels>
    <parcel>
    <trackingBarcode>312014853400000769000219190151</trackingBarcode>
    <relabelBarcode>EA139466856BE</relabelBarcode>
    <senderName>QUEAL</senderName>
    <destinationName>Hunar Khanna</destinationName>
    <deliveryStatus>
      <status>
        <dateTime>07-02-2018 15:30:29</dateTime>
        <status>
          <nl>Zending is aangekondigd / bpost heeft de informatie ontvangen</nl>
          <fr>Envoi est annoncé / bpost a reçu l'information</fr>
          <de>Sendung angekündigt / bpost hat Information erhalten</de>
          <en>Item is announced / bpost received the information</en>
        </status>
        <statusCode>BI1</statusCode>
      </status>
      <status>
        <location>Belgium</location>
        <dateTime>08-02-2018 02:49:38</dateTime>
        <status>
          <nl>bpost heeft het zending in ontvangst genomen</nl>
          <fr>bpost a reçu l'envoi</fr>
          <de>bpost hat Sendung erhalten</de>
          <en>bpost has received the item</en>
        </status>
        <statusCode>BI2</statusCode>
      </status>
      <status>
        <location>Singapore</location>
        <dateTime>12-02-2018 13:04:00</dateTime>
        <status>
          <nl>Zending geleverd</nl>
          <fr>Envoi distribué</fr>
          <de>Sendung zugestellt</de>
          <en>Item delivered</en>
        </status>
        <statusCode>U01</statusCode>
      </status>
    </deliveryStatus>
  </parcel>
</parcels>
                             """

                         parseResult : Result String (List Status)
                         parseResult  =
                                Decoders.parseHttpResponse httpResponse

                     in
                         case parseResult of
                                Ok parsedStatusList -> Expect.equal (List.length parsedStatusList) 3
                                Err error ->
                                    Expect.fail (
                                        "Parse failed: " ++ (toString error)
                                    )

             , test "can parse dates" <|
                  \_ ->
                      let
                          dateString = "28-01-2018 16:27:00"

                          parsedDate : Result String Date
                          parsedDate = Decoders.fromString dateString
                      in
                          case parsedDate of
                                Ok date ->
                                    Expect.all
                                        [ \d -> Expect.equal (Date.day d) 28
                                        , \d -> Expect.equal (Date.month d) Date.Jan
                                        , \d -> Expect.equal (Date.year d) 2018
                                        , \d -> Expect.equal (Date.hour d) 16
                                        , \d -> Expect.equal (Date.minute d) 27
                                        , \d -> Expect.equal (Date.second d) 0
                                        ]
                                        date

                                Err error -> Expect.fail error
             ]
        ]
