module Hour.Ext exposing (..)

import Hour
import Json.Decode as D exposing (Decoder)
import Json.Encode as E


encoder : Hour.Time -> E.Value
encoder =
    E.string << Hour.toIsoString


decoder : Decoder Hour.Time
decoder =
    D.andThen
        (\str ->
            Maybe.withDefault (D.fail ("Invalid ISO time string: " ++ str)) <|
                Maybe.map D.succeed <|
                    Hour.fromIsoString str
        )
        D.string
