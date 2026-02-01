module Date.Ext exposing (..)

import Date exposing (Date)
import Json.Decode as D exposing (Decoder)


decoder : Decoder Date
decoder =
    D.andThen
        (Result.mapErr D.fail
            < Result.map D.succeed
            << Date.fromIsoString
        )
        D.string
