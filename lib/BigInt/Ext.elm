module BigInt.Ext exposing (..)

import BigInt exposing (BigInt)
import Json.Decode as D exposing (Decoder)
import Maybe.Extra
import S


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
