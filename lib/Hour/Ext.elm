module Hour.Ext exposing (..)

import Hour
import Json.Decode as D exposing (Decoder)
import Json.Encode as E


{-| NOT `Hour.toIsoString`: that drops the `:ss` segment for whole-minute times
("06:00"), which `Hour.fromIsoString` — and so `decoder` below — refuses. The
package's own ISO pair is not a round trip; always emit all three segments.
(Milliseconds are dropped; nothing we encode carries them.)
-}
encoder : Hour.Time -> E.Value
encoder t =
    let
        pad : Int -> String
        pad =
            String.padLeft 2 '0' << String.fromInt
    in
    E.string (pad (Hour.hours t) ++ ":" ++ pad (Hour.minutes t) ++ ":" ++ pad (Hour.seconds t))


decoder : Decoder Hour.Time
decoder =
    D.andThen
        (\str ->
            Maybe.withDefault (D.fail ("Invalid ISO time string: " ++ str)) <|
                Maybe.map D.succeed <|
                    Hour.fromIsoString str
        )
        D.string
