module OrderForm.View exposing (view)

import Html exposing ( div
                     , Html
                     , input
                     , button
                     , text
                     , select
                     , option
                     )
import Html.Attributes exposing ( class
                                , classList
                                , placeholder
                                , value
                                , property
                                , disabled
                                , selected
                                )

import Html.Events exposing ( onInput
                            , onClick
                            , on
                            )

import Debug exposing (log)
import Json.Decode as Decode exposing ( succeed
                            , Decoder)

import CommonModel
import Utilities
import OrderForm.Model exposing (Model)
import OrderForm.Message exposing (Msg(..))

view : Model -> Html Msg
view model =
    div [ classList [ ("input-group", True)
                    , ("input-group-sm", True)
                    , ("p-2", True)
                    ]]
        [ div [ classList [ ("col-8", True)
                          ]
              ]
              [ input [ placeholder "Enter id to track"
                      , classList [ ("form-control", True)
                                  , ("form-control-sm", True)
                                  ]
                     -- setting value here is crucial to making it declarative
                      , value model.trackingId
                      , onInput (\newInput -> TrackingIdChanged newInput)
                      ] []
              ]
        , div [ classList [ ("col-2", True)
                          ]
              ]
              [ createVendorSelectionMenu model]
        , createSubmitButton model
        ]

vendorDecoder : Decoder (Maybe CommonModel.Vendor)
vendorDecoder =
    let
        findMatchingVendor : String -> Maybe CommonModel.Vendor
        findMatchingVendor selectedValue =
            Utilities.supportedVendors
                |> List.filter (\vendor -> vendor.id == selectedValue)
                |> List.head
    in
        Decode.map findMatchingVendor Html.Events.targetValue


createVendorSelectionMenu : Model -> Html Msg
createVendorSelectionMenu model =
    let
        createOption : CommonModel.Vendor -> Html Msg
        createOption vendor =
            option [value vendor.id] [text vendor.name]

        createSelectWithOptions : List (Html Msg) -> Html Msg
        createSelectWithOptions options =
            select [ classList [ ("custom-select", True)
                               , ("form-control-sm", True)
                               ]
                   ,  on "change" (Decode.map VendorChanged vendorDecoder)
                   ] options

        headerOption : Bool -> Html Msg
        headerOption isActive =
            option [ selected isActive
                   ] [ text "Select vendor" ]
    in
        case model.selectedVendor of
            Just vendor ->
                let
                    createOptionForVendor : CommonModel.Vendor -> Html Msg
                    createOptionForVendor current =
                        option [ selected (vendor.id == current.id)
                               , value current.id]
                            [text vendor.name]
                in
                    createSelectWithOptions
                        (headerOption False :: List.map createOptionForVendor Utilities.supportedVendors)
            Nothing ->
                createSelectWithOptions
                    (headerOption True :: (List.map createOption Utilities.supportedVendors))


createSubmitButton : Model -> Html Msg
createSubmitButton model =
    let
        commonAttributes : List (Html.Attribute Msg)
        commonAttributes =
            [ classList [ ("btn", True)
                        , ("btn-success", True)
                        , ("btn-sm", True)
                        , ("btn-block", True)
                        ]
            ]

        isSubmissionAllowed : List (Html.Attribute Msg)
        isSubmissionAllowed =
            case model.selectedVendor of
                Nothing ->
                    -- TODO: disable the button with a tooltip message or something
                    [disabled True]
                Just vendor ->
                    [onClick (SubmitForm vendor model.trackingId)]


        buttonAttributes : List (Html.Attribute Msg)
        buttonAttributes =
            commonAttributes ++ isSubmissionAllowed
    in
        div [ classList [ ("col-2", True)] ]
            [ button buttonAttributes
                  [ text "Save"]
            ]
