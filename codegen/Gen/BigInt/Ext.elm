module Gen.BigInt.Ext exposing ( moduleName_, decoder, values_ )

{-|
# Generated bindings for BigInt.Ext

@docs moduleName_, decoder, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "BigInt", "Ext" ]


{-| decoder: Json.Decode.Decoder BigInt.BigInt -}
decoder : Elm.Expression
decoder =
    Elm.value
        { importFrom = [ "BigInt", "Ext" ]
        , name = "decoder"
        , annotation =
            Just
                (Type.namedWith
                     [ "Json", "Decode" ]
                     "Decoder"
                     [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                )
        }


values_ : { decoder : Elm.Expression }
values_ =
    { decoder =
        Elm.value
            { importFrom = [ "BigInt", "Ext" ]
            , name = "decoder"
            , annotation =
                Just
                    (Type.namedWith
                         [ "Json", "Decode" ]
                         "Decoder"
                         [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                    )
            }
    }