module FunctionalTests exposing (..)


import Expect exposing (Expectation)
import Test exposing (..)
import Models.Types as Bpost exposing (..)

import Date exposing (Date)


suite : Test
suite =
    let
        status1 : Bpost.Status
        status1 =
            { dateTime = Date.fromTime 1000000
            , statusMessage = "message 1"
            , location = Just "sg"
            }

        status2 : Bpost.Status
        status2 =
            { dateTime = Date.fromTime 3000000
            , statusMessage = "message 2"
            , location = Just "in"
            }

    in
        describe "Model.Types"
            [ describe "mostRecentStatus"
                  [ test "fetch the most recent status from a non-empty list of statuses " <|
                        \_ ->
                            Expect.all
                                [ Expect.equal (mostRecentStatus [status1, status2])
                                , Expect.equal (mostRecentStatus [status2, status1])
                                ] (Just status2)
                  , test "returns Nothing for an empty list of statuses" <|
                        \_ ->
                            Expect.equal (mostRecentStatus []) Nothing
                  ]
            ]
