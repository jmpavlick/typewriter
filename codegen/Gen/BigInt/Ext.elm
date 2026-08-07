module Gen.BigInt.Ext exposing
    ( moduleName_, decoder, encoder, call_, values_
    )

{-|
# Generated bindings for BigInt.Ext

@docs moduleName_, decoder, encoder, call_, values_
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


{-| {-| decimal string, which `decoder` accepts via `BigInt.fromIntString`
-}

encoder: BigInt.BigInt -> Json.Encode.Value
-}
encoder : Elm.Expression -> Elm.Expression
encoder encoderArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt", "Ext" ]
             , name = "encoder"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                          (Type.namedWith [ "Json", "Encode" ] "Value" [])
                     )
             }
        )
        [ encoderArg_ ]


call_ : { encoder : Elm.Expression -> Elm.Expression }
call_ =
    { encoder =
        \encoderArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt", "Ext" ]
                     , name = "encoder"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                                  (Type.namedWith
                                       [ "Json", "Encode" ]
                                       "Value"
                                       []
                                  )
                             )
                     }
                )
                [ encoderArg_ ]
    }


values_ : { decoder : Elm.Expression, encoder : Elm.Expression }
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
    , encoder =
        Elm.value
            { importFrom = [ "BigInt", "Ext" ]
            , name = "encoder"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                         (Type.namedWith [ "Json", "Encode" ] "Value" [])
                    )
            }
    }