module FunctionalTests exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)

import Date exposing (Date)

import Model exposing (..)
import Utilities


suite : Test
suite =
    let
        status1 : Status
        status1 =
            { dateTime = Date.fromTime 1000000
            , statusMessage = "message 1"
            , location = Just "sg"
            }

        status2 : Status
        status2 =
            { dateTime = Date.fromTime 3000000
            , statusMessage = "message 2"
            , location = Just "in"
            }


        orderList : List Model.Order
        orderList =
            [ { trackingId = "o1"
              , statusList = [ status1 ]
              }
            , { trackingId = "o2"
              , statusList = [ status2, status1 ]
              }
            ]
    in
        describe "Tests on common functions"
            [ describe "Models.Types.mostRecentStatus"
                  [ test "fetch the most recent status from a non-empty list of statuses " <|
                        \_ ->
                            Expect.all
                                [ Expect.equal (Utilities.mostRecentStatus [status1, status2])
                                , Expect.equal (Utilities.mostRecentStatus [status2, status1])
                                ] (Just status2)
                  , test "returns Nothing for an empty list of statuses" <|
                        \_ ->
                            Expect.equal (Utilities.mostRecentStatus []) Nothing
                  ]
            , describe "App.updateOrder" <|
                  [ test "updates an existing order i.e order with same tracking id" <|
                        \_ ->
                            let
                                updatedOrder =
                                    { trackingId = "o1"
                                    , statusList = [ status1, status2 ]
                                    }
                            in
                                Expect.equal
                                    (Utilities.updateOrder orderList updatedOrder)
                                    [ updatedOrder
                                    , { trackingId = "o2"
                                      , statusList = [ status2, status1 ]
                                      }
                                    ]

                  ]
            ]
