module Url.Ext exposing (..)

import Json.Decode as D exposing (Decoder)
import Json.Encode as E
import Url exposing (Url)


encoder : Url -> E.Value
encoder =
    E.string << Url.toString


decoder : Decoder Url
decoder =
    D.andThen
        (Maybe.withDefault (D.fail "Could not decode string as URL")
            << Maybe.map D.succeed
            << Url.fromString
        )
        D.string
