module AftershipTests exposing (..)

import Json.Decode as JsDecode
import Json.Encode as Json
import Date

import Test exposing (..)
import Expect exposing (Expectation)

import VendorInfo.Aftership as Aftership

suite : Test
suite =
    describe "Aftership"
        [ describe "orderListDecoder"
              [ test "can decode json into correct list of orders" <|
                    \_ ->
                        let
                            jsonString : String
                            jsonString =
                                    """
  {
    "meta": {
        "code": 200
    },
    "data": {
        "page": 1,
        "limit": 100,
        "count": 3,
        "keyword": "",
        "slug": "",
        "origin": [],
        "destination": [],
        "tag": "",
        "fields": "",
        "created_at_min": "2014-03-27T07:36:14+00:00",
        "created_at_max": "2014-06-25T07:36:14+00:00",
        "trackings": [
            {
                "id": "53aa7b5c415a670000000021",
                "created_at": "2014-06-25T07:33:48+00:00",
                "updated_at": "2014-06-25T07:33:55+00:00",
                "tracking_number": "123456789",
                "tracking_account_number": null,
                "tracking_postal_code": null,
                "tracking_ship_date": null,
                "slug": "dhl",
                "active": false,
                "custom_fields": {
                    "product_price": "USD19.99",
                    "product_name": "iPhone Case"
                },
                "customer_name": null,
                "destination_country_iso3": null,
                "emails": [
                    "email@yourdomain.com",
                    "another_email@yourdomain.com"
                ],
                "expected_delivery": null,
                "note": null,
                "order_id": "ID 1234",
                "order_id_path": "http://www.aftership.com/order_id=1234",
                "origin_country_iso3": null,
                "shipment_package_count": 0,
                "shipment_type": null,
                "signed_by": "raul",
                "smses": [],
                "source": "api",
                "tag": "Delivered",
                "title": "Title Name",
                "tracked_count": 1,
                "unique_token": "xy_fej9Llg",
                "language": "en",
                "checkpoints": [
                    {
                        "slug": "dhl",
                        "city": null,
                        "created_at": "2014-06-25T07:33:53+00:00",
                        "country_name": "VALENCIA - SPAIN",
                        "message": "Awaiting collection by recipient as requested",
                        "country_iso3": null,
                        "tag": "InTransit",
                        "checkpoint_time": "2014-05-12T12:02:00",
                        "coordinates": [],
                        "state": null,
                        "zip": null
                    }
                ]
            }
        ]
    }
}

                                    """

                            decodeResult : Result String Json.Value
                            decodeResult =
                                JsDecode.decodeString JsDecode.value jsonString

                            expectJust : Maybe a -> (a -> Expectation) -> Expectation
                            expectJust optional f =
                                case optional of
                                       Just x -> f x
                                       Nothing -> Expect.fail "Got nothing"
                        in
                            case decodeResult of
                                Ok json ->
                                    case (Aftership.parseJson json) of
                                       Ok orderList ->
                                           Expect.all
                                               [ \l -> Expect.equal (List.length l) 1
                                               , \list ->
                                                   expectJust
                                                       (List.head list)
                                                       (\order ->
                                                           Expect.all
                                                               [ \o -> (Expect.equal order.trackingId "53aa7b5c415a670000000021")
                                                               , \o -> (Expect.equal order.trackingNumber "123456789")
                                                               , \o -> (Expect.equal order.slugId "dhl")
                                                               , \o ->
                                                                   Expect.all
                                                                       [ \sList -> Expect.equal (List.length sList) 1
                                                                       , \sList ->
                                                                           expectJust
                                                                           (List.head sList)
                                                                           (\status ->
                                                                               Expect.all
                                                                                   [ \s -> Expect.equal s.statusMessage "Awaiting collection by recipient as requested"
                                                                                   , \s -> Expect.equal s.location (Just "VALENCIA - SPAIN")
                                                                                   , \s -> Expect.equal (Date.day (s.dateTime)) 12
                                                                                   , \s -> Expect.equal (Date.month (s.dateTime)) Date.May
                                                                                   , \s -> Expect.equal (Date.year (s.dateTime)) 2014
                                                                                   , \s -> Expect.equal (Date.hour s.dateTime) 12
                                                                                   , \s -> Expect.equal (Date.minute s.dateTime) 2
                                                                                   , \s -> Expect.equal (Date.second s.dateTime) 0
                                                                                   ]
                                                                                   status)
                                                                       ]
                                                                       o.statusList
                                                               ]
                                                               order)
                                               ]
                                               orderList
                                       Err errString ->
                                           Expect.fail errString
                                Err errString ->
                                    Expect.fail errString
              ]
        ]
