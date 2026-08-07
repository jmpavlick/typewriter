module Gen.Hour.Ext exposing
    ( moduleName_, decoder, encoder, call_, values_
    )

{-|
# Generated bindings for Hour.Ext

@docs moduleName_, decoder, encoder, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Hour", "Ext" ]


{-| decoder: Json.Decode.Decoder Hour.Time -}
decoder : Elm.Expression
decoder =
    Elm.value
        { importFrom = [ "Hour", "Ext" ]
        , name = "decoder"
        , annotation =
            Just
                (Type.namedWith
                     [ "Json", "Decode" ]
                     "Decoder"
                     [ Type.namedWith [ "Hour" ] "Time" [] ]
                )
        }


{-| encoder: Hour.Time -> Json.Encode.Value -}
encoder : Elm.Expression -> Elm.Expression
encoder encoderArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour", "Ext" ]
             , name = "encoder"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Time" [] ]
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
                     { importFrom = [ "Hour", "Ext" ]
                     , name = "encoder"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Time" [] ]
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
            { importFrom = [ "Hour", "Ext" ]
            , name = "decoder"
            , annotation =
                Just
                    (Type.namedWith
                         [ "Json", "Decode" ]
                         "Decoder"
                         [ Type.namedWith [ "Hour" ] "Time" [] ]
                    )
            }
    , encoder =
        Elm.value
            { importFrom = [ "Hour", "Ext" ]
            , name = "encoder"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Time" [] ]
                         (Type.namedWith [ "Json", "Encode" ] "Value" [])
                    )
            }
    }