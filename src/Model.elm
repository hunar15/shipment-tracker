module Model exposing (..)

import OrderForm.Model as FormModel
import CommonModel

type alias Model = { activeOrders : List CommonModel.Order
                   , aftershipOrders : List CommonModel.AftershipOrder
                   , formModel : FormModel.Model
                   , errorMessage : String
                   , aftershipApiKey : String
                   }
