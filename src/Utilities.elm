module Utilities exposing (..)

import Date exposing (Date)
import Json.Encode as Json
import Json.Decode as JsDecode

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

-- TODO: remove later
-- bpostInfo : Vendor
-- bpostInfo =
--     { name = "Bpost"
--      , id = "bpost"
--      , endpointMaker =
--            \trackingId ->
--                "http://www.bpost2.be/bpostinternational/track_trace/find.php?search=s&lng=en&trackcode=" ++ trackingId
--      , responseDecoder = BpostInfo.parseHttpResponse
--      }

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
