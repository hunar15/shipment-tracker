port module Main exposing (..)

import Html

import Model exposing (..)
import Message exposing (Msg(..))
import CommonModel
import View exposing (view)
import Update exposing (update)
import OrderForm.Model exposing (emptyForm)

main =
  Html.program { subscriptions = subscriptions
               , view = view
               , update = update
               , init = init }

init : (Model, Cmd Msg)
init = ({ activeOrders = []
        , formModel = emptyForm
        }
       , Cmd.none)


--- SUBSCRIPTIONS ---

port loadTrackingIds : (List CommonModel.TrackingId -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  loadTrackingIds LoadTrackingInformation

--- initial orders ---
--- 312014853400000769000219190151 Bpost
