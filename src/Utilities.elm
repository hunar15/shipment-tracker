module Utilities exposing (..)

import Date exposing (Date)
import Json.Encode as Json
import Json.Decode as JsDecode
import Http

import CommonModel as Model exposing (..)
import VendorInfo.Bpost as BpostInfo

createInitOrders : Json.Value ->  Result String (List Model.Order)
createInitOrders ordersJson =
    let
        vendorDecoder : JsDecode.Decoder Vendor
        vendorDecoder =
            JsDecode.field "vendorId" JsDecode.string
                |> JsDecode.andThen (\vendorId ->
                                         case findVendorInfoById vendorId of
                                             Just vendor -> JsDecode.succeed vendor
                                             Nothing -> JsDecode.fail ("couldn't find info for vendor : " ++ vendorId)
                                    )

        orderDecoder : JsDecode.Decoder Model.Order
        orderDecoder =
            JsDecode.map2 (\vendor trackingId -> { trackingId = trackingId
                                                 , vendor = vendor
                                                 , statusList = []
                                                 })
                vendorDecoder (JsDecode.field "trackingId" JsDecode.string)


        orderListDecoder : JsDecode.Decoder (List Model.Order)
        orderListDecoder =
            JsDecode.list orderDecoder
    in
        JsDecode.decodeValue orderListDecoder ordersJson

createPersistableOrder : Model.Order -> Json.Value
createPersistableOrder order =
    Json.object [ ("trackingId", Json.string order.trackingId)
                , ("vendorId", Json.string order.vendor.id)
                ]

findVendorInfoById : String -> Maybe Vendor
findVendorInfoById vendorId =
    List.filter (\vendor -> vendor.id == vendorId) supportedVendors
        |> List.head

mostRecentStatus : List Status -> Maybe Status
mostRecentStatus statusList =
    let
        latestDateComparer status =
            status.dateTime
                |> Date.toTime
                |> negate
    in
        List.sortBy latestDateComparer statusList
            |> List.head


updateOrder : List Model.Order -> Model.Order -> List Model.Order
updateOrder orderList newOrder =
    let
        updater : Model.Order -> Model.Order
        updater oldOrder =
            if oldOrder.trackingId == newOrder.trackingId then
                newOrder
            else
                oldOrder
    in
        List.map updater orderList


createNewOrder : TrackingId -> Model.Vendor-> Model.Order
createNewOrder trackingId vendorInfo =
    { trackingId = trackingId
    , vendor = vendorInfo
    , statusList = []
    }

supportedVendors : List Vendor
supportedVendors =
    [ { name = "Bpost"
      , id = "bpost"
      , endpointMaker =
            \trackingId ->
                "http://www.bpost2.be/bpostinternational/track_trace/find.php?search=s&lng=en&trackcode=" ++ trackingId
      , responseDecoder = BpostInfo.parseHttpResponse
      }
    ]


httpRequestForAftershipOrders : String -> Http.Request Json.Value
httpRequestForAftershipOrders apiKey =
    Http.request { method = "GET"
                 , headers = [Http.header "aftership-api-key" apiKey]
                 , body = Http.emptyBody
                 , timeout = Nothing
                 , url = "https://api.aftership.com/v4/trackings"
                 , expect = Http.expectJson JsDecode.value
                 , withCredentials = False
                 }


deleteAftershipOrderRequest : String -> String -> Http.Request Json.Value
deleteAftershipOrderRequest apiKey trackingId =
    Http.request { method = "DELETE"
                 , headers = [Http.header "aftership-api-key" apiKey]
                 , body = Http.emptyBody
                 , timeout = Nothing
                 , url = "https://api.aftership.com/v4/trackings/" ++ trackingId
                 , expect = Http.expectJson JsDecode.value
                 , withCredentials = False
                 }

