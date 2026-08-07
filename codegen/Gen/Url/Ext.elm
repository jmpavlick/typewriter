module Gen.Url.Ext exposing
    ( moduleName_, decoder, encoder, call_, values_
    )

{-|
# Generated bindings for Url.Ext

@docs moduleName_, decoder, encoder, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Url", "Ext" ]


{-| decoder: Json.Decode.Decoder Url.Url -}
decoder : Elm.Expression
decoder =
    Elm.value
        { importFrom = [ "Url", "Ext" ]
        , name = "decoder"
        , annotation =
            Just
                (Type.namedWith
                     [ "Json", "Decode" ]
                     "Decoder"
                     [ Type.namedWith [ "Url" ] "Url" [] ]
                )
        }


{-| encoder: Url.Url -> Json.Encode.Value -}
encoder : Elm.Expression -> Elm.Expression
encoder encoderArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Url", "Ext" ]
             , name = "encoder"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Url" ] "Url" [] ]
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
                     { importFrom = [ "Url", "Ext" ]
                     , name = "encoder"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Url" ] "Url" [] ]
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
            { importFrom = [ "Url", "Ext" ]
            , name = "decoder"
            , annotation =
                Just
                    (Type.namedWith
                         [ "Json", "Decode" ]
                         "Decoder"
                         [ Type.namedWith [ "Url" ] "Url" [] ]
                    )
            }
    , encoder =
        Elm.value
            { importFrom = [ "Url", "Ext" ]
            , name = "encoder"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Url" ] "Url" [] ]
                         (Type.namedWith [ "Json", "Encode" ] "Value" [])
                    )
            }
    }