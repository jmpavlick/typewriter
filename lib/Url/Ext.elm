module Url.Ext exposing (..)

import Json.Decode as D exposing (Decoder)
import Url exposing (Url)


decoder : Decoder Url
decoder =
    D.andThen
        (Maybe.withDefault (D.fail "Could not decode string as URL")
            << Maybe.map D.succeed
            << Url.fromString
        )
        D.string
