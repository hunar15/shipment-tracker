port module Main exposing (..)

import Html
import Json.Encode as Json
import Task
import Time

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
        , aftershipOrders = []
        , formModel = emptyForm
        , errorMessage = ""
        , aftershipApiKey = aftershipApiKey
        }
       , Task.perform (\_ -> FetchAftershipOrders) Time.now)

aftershipApiKey : String
aftershipApiKey = "1107b760-aa92-4eda-8c1d-132aab782b88"

--- SUBSCRIPTIONS ---

port loadTrackingIds : (Json.Value -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  loadTrackingIds LoadTrackingInformation

--- initial orders ---
--- 312014853400000769000219190151 Bpost
