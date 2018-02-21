module View exposing (..)

import Html exposing (ul, li, button, text, Html, h5, div, small, input)
import Html.Attributes exposing (class, classList, placeholder)

import Model exposing (..)
import Message exposing (Msg)
import Utilities

newOrderView : Html Msg
newOrderView =
    --- TODO is input group actually doing anythin?
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
                       ]
                    [ text "Save"]
              ]
        ]



view : Model -> Html Msg
view model =
  let
      createRow : Model.Order -> Html Msg
      createRow order =
          li [ class "list-group-item" ]
             [ div [ class "row" ]
                   [ div [ class "col-6" ]
                         [ small []
                                 [ text order.trackingId ]
                         ]
                   , div [ class "col-6" ]
                         [ text ((Maybe.withDefault "no message available")
                                     (Maybe.map .statusMessage (Utilities.mostRecentStatus order.statusList))
                                )
                         ]
                   ]
             ]
  in
      div [ classList [ ("panel", True)
                      , ("panel-default", True)]
          ]
          [ ul [ class "list-group" ]
                ((List.map createRow model) ++

                    [ newOrderView
                    ]
                )
          ]
