module Utilities exposing (..)

import Date exposing (Date)
import Http

import CommonModel as Model exposing (..)
import Message exposing (Msg(..))
import VendorInfo.Bpost as BpostInfo

createInitOrders : List TrackingId ->  List Model.Order
createInitOrders trackingIds =
        List.map (\trackingId ->
                      createNewOrder trackingId bpostInfo)
            trackingIds


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
bpostInfo : Vendor
bpostInfo =
    { name = "Bpost"
     , id = "bpost"
     , endpointMaker =
           \trackingId ->
               "http://www.bpost2.be/bpostinternational/track_trace/find.php?search=s&lng=en&trackcode=" ++ trackingId
     , responseDecoder = BpostInfo.parseHttpResponse
     }

supportedVendors : List Vendor
supportedVendors =
    [ bpostInfo ]
