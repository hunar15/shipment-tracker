module DecoderTests exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import Models.Types as Bpost exposing (..)

import Date exposing (Date)

import Xml.Decode as XD exposing ( path
                           , single
                           , string )

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
                       expectedDateResult = Date.fromString "07-02-2018 15:30:29"
                   in
                       case expectedDateResult of
                           Ok parsedDate ->
                               Expect.equal
                                   (XD.run Bpost.statusDecoder xmlString)
                                   (Ok (Status { dateTime = parsedDate
                                               , statusMessage = StatusMessage "Parcel is handled"
                                               , location = Just "Belgium"
                                               }))
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
                             (XD.run Bpost.statusMessageDecoder xmlString)
                             (Ok (Bpost.StatusMessage "Parcel is handled"))
             ]
        ]
