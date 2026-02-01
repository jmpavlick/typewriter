module Date.Ext exposing (..)

import Date exposing (Date)
import Json.Decode as D exposing (Decoder)


decoder : Decoder Date
decoder =
    D.andThen
        (\str ->
            case Date.fromIsoString str of
                Ok ok ->
                    D.succeed ok

                Err e ->
                    D.fail e
        )
        D.string
