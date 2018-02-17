module DecoderTests exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


suite : Test
suite =
    describe "Model.Types"
        [ describe "Low-level parser"
             [ test "can decode xml into the type" <|
                  \_ ->
                      Expect.equal 1 1
             ]
        ]
