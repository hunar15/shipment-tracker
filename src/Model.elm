module Model exposing (..)

import OrderForm.Model as FormModel
import CommonModel

type alias Model = { activeOrders : List CommonModel.Order
                   , formModel : FormModel.Model
                   }
