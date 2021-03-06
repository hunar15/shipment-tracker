module View exposing (..)

import Html exposing (ul, li, button, text, Html, h5, div, small, input, i, a)
import Html.Attributes exposing (class, classList, placeholder, value, property, href, style)
import Html.Events exposing (onInput, onClick)

import Model exposing (..)
import Message exposing (Msg(..))
import OrderForm.View as FormView
import Utilities

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
                   , div [ class "col-2" ]
                         [ a [ onClick (DeleteOrder order.trackingId)
                             , href "#"
                             , class "text-danger"
                             ]
                               [i [ classList [ ("fa", True)
                                              , ("fa-minus-circle", True)
                                              ]]
                                    []
                               ]
                         ]
                   , div [ class "col-4" ]
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
                ((List.map createRow model.activeOrders) ++ [Html.map FormMessage (FormView.view model.formModel)])
          ]
