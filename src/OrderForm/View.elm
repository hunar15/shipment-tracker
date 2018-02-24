module OrderForm.View exposing (view)

import Html exposing ( div
                     , Html
                     , input
                     , button
                     , text
                     )
import Html.Attributes exposing ( class
                                , classList
                                , placeholder
                                , value
                                )

import Html.Events exposing ( onInput
                            , onClick
                            )

import OrderForm.Model exposing (Model)
import OrderForm.Message exposing (Msg(..))

view : Model -> Html Msg
view model =
    div [ classList [ ("input-group", True)
                    , ("input-group-sm", True)
                    ]]
        [ div [ classList [ ("p-2", True)
                          , ("col-10", True)
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
        , div [ classList [ ("p-2", True)
                          , ("col-2", True)
                          ]
              ]
              [ button [ classList [ ("btn", True)
                                   , ("btn-success", True)
                                   , ("btn-sm", True)
                                   , ("btn-block", True)
                                   ]
                       , onClick (SubmitForm model.trackingId)
                       ]
                    [ text "Save"]
              ]
        ]
