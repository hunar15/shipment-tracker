module DecoderTests exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import Models.Types as Bpost exposing (..)

import Xml.Decode as XD exposing ( path
                           , single
                           , string )

suite : Test
suite =
    describe "Model.Types"
        [ describe "StatusDecoder"
             [ test "can decode xml value into correct type" <|
                  \_ ->
                   let
                       xmlString =
                           """
                           <status>
                            <location>Belgium</location>
                            <dateTime>someDateTime</dateTime>
                            <status>
                            <en>Parcel is handled</en>
                            </status>
                            <statusCode>BI3</statusCode>
                           </status>
                           """
                   in
                       Expect.equal
                           (XD.run Bpost.statusDecoder xmlString)
                           (Ok (Status { dateTime = "someDateTime"
                                       , statusMessage = StatusMessage "Parcel is handled"
                                       , location = Just "Belgium"
                                       }))

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
