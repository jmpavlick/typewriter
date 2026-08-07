module BigInt.Ext exposing (..)

import BigInt exposing (BigInt)
import Json.Decode as D exposing (Decoder)
import Json.Encode as E
import Maybe.Extra
import S


{-| decimal string, which `decoder` accepts via `BigInt.fromIntString`
-}
encoder : BigInt -> E.Value
encoder =
    E.string << BigInt.toString


decoder : Decoder BigInt
decoder =
    D.oneOf
        [ D.map BigInt.fromInt D.int
        , D.string
            |> D.andThen
                (Maybe.withDefault (D.fail "Could not decode value as BigInt")
                    << Maybe.map D.succeed
                    << S.s2 Maybe.Extra.or
                        BigInt.fromIntString
                        BigInt.fromHexString
                )
        ]
