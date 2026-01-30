module Json.Decode.Ext exposing (..)

import Json.Decode as D


andMap : D.Decoder a -> D.Decoder (a -> b) -> D.Decoder b
andMap =
    D.map2 (|>)
