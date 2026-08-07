module Gen.Date.Ext exposing
    ( moduleName_, decoder, encoder, call_, values_
    )

{-|
# Generated bindings for Date.Ext

@docs moduleName_, decoder, encoder, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Date", "Ext" ]


{-| decoder: Json.Decode.Decoder Date.Date -}
decoder : Elm.Expression
decoder =
    Elm.value
        { importFrom = [ "Date", "Ext" ]
        , name = "decoder"
        , annotation =
            Just
                (Type.namedWith
                     [ "Json", "Decode" ]
                     "Decoder"
                     [ Type.namedWith [ "Date" ] "Date" [] ]
                )
        }


{-| encoder: Date.Date -> Json.Encode.Value -}
encoder : Elm.Expression -> Elm.Expression
encoder encoderArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Date", "Ext" ]
             , name = "encoder"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Date" ] "Date" [] ]
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
                     { importFrom = [ "Date", "Ext" ]
                     , name = "encoder"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Date" ] "Date" [] ]
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
            { importFrom = [ "Date", "Ext" ]
            , name = "decoder"
            , annotation =
                Just
                    (Type.namedWith
                         [ "Json", "Decode" ]
                         "Decoder"
                         [ Type.namedWith [ "Date" ] "Date" [] ]
                    )
            }
    , encoder =
        Elm.value
            { importFrom = [ "Date", "Ext" ]
            , name = "encoder"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Date" ] "Date" [] ]
                         (Type.namedWith [ "Json", "Encode" ] "Value" [])
                    )
            }
    }