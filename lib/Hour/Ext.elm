module Hour.Ext exposing (..)

import Hour
import Json.Decode as D exposing (Decoder)


decoder : Decoder Hour.Time
decoder =
    D.andThen
        (Result.mapErr D.fail
            << Result.map D.succeed
            << Hour.fromIsoString
        )
        D.string
