module Gen.Javascript exposing
    ( moduleName_, nullDecoder, nullEncoder, undefinedDecoder, undefinedEncoder, voidDecoder
    , voidEncoder, nanDecoder, nanEncoder, annotation_, make_, caseOf_, call_
    , values_
    )

{-|
# Generated bindings for Javascript

@docs moduleName_, nullDecoder, nullEncoder, undefinedDecoder, undefinedEncoder, voidDecoder
@docs voidEncoder, nanDecoder, nanEncoder, annotation_, make_, caseOf_
@docs call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Arg
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Javascript" ]


{-| nullDecoder: Json.Decode.Decoder Javascript.Null -}
nullDecoder : Elm.Expression
nullDecoder =
    Elm.value
        { importFrom = [ "Javascript" ]
        , name = "nullDecoder"
        , annotation =
            Just
                (Type.namedWith
                     [ "Json", "Decode" ]
                     "Decoder"
                     [ Type.namedWith [ "Javascript" ] "Null" [] ]
                )
        }


{-| nullEncoder: Javascript.Null -> Json.Encode.Value -}
nullEncoder : Elm.Expression -> Elm.Expression
nullEncoder nullEncoderArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Javascript" ]
             , name = "nullEncoder"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Javascript" ] "Null" [] ]
                          (Type.namedWith [ "Json", "Encode" ] "Value" [])
                     )
             }
        )
        [ nullEncoderArg_ ]


{-| undefinedDecoder: Json.Decode.Decoder Javascript.Undefined -}
undefinedDecoder : Elm.Expression
undefinedDecoder =
    Elm.value
        { importFrom = [ "Javascript" ]
        , name = "undefinedDecoder"
        , annotation =
            Just
                (Type.namedWith
                     [ "Json", "Decode" ]
                     "Decoder"
                     [ Type.namedWith [ "Javascript" ] "Undefined" [] ]
                )
        }


{-| undefinedEncoder: Javascript.Undefined -> Json.Encode.Value -}
undefinedEncoder : Elm.Expression -> Elm.Expression
undefinedEncoder undefinedEncoderArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Javascript" ]
             , name = "undefinedEncoder"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Javascript" ] "Undefined" [] ]
                          (Type.namedWith [ "Json", "Encode" ] "Value" [])
                     )
             }
        )
        [ undefinedEncoderArg_ ]


{-| voidDecoder: Json.Decode.Decoder Javascript.Void -}
voidDecoder : Elm.Expression
voidDecoder =
    Elm.value
        { importFrom = [ "Javascript" ]
        , name = "voidDecoder"
        , annotation =
            Just
                (Type.namedWith
                     [ "Json", "Decode" ]
                     "Decoder"
                     [ Type.namedWith [ "Javascript" ] "Void" [] ]
                )
        }


{-| voidEncoder: Javascript.Void -> Json.Encode.Value -}
voidEncoder : Elm.Expression -> Elm.Expression
voidEncoder voidEncoderArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Javascript" ]
             , name = "voidEncoder"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Javascript" ] "Void" [] ]
                          (Type.namedWith [ "Json", "Encode" ] "Value" [])
                     )
             }
        )
        [ voidEncoderArg_ ]


{-| nanDecoder: Json.Decode.Decoder Javascript.NaN -}
nanDecoder : Elm.Expression
nanDecoder =
    Elm.value
        { importFrom = [ "Javascript" ]
        , name = "nanDecoder"
        , annotation =
            Just
                (Type.namedWith
                     [ "Json", "Decode" ]
                     "Decoder"
                     [ Type.namedWith [ "Javascript" ] "NaN" [] ]
                )
        }


{-| nanEncoder: Javascript.NaN -> Json.Encode.Value -}
nanEncoder : Elm.Expression -> Elm.Expression
nanEncoder nanEncoderArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Javascript" ]
             , name = "nanEncoder"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Javascript" ] "NaN" [] ]
                          (Type.namedWith [ "Json", "Encode" ] "Value" [])
                     )
             }
        )
        [ nanEncoderArg_ ]


annotation_ :
    { any : Type.Annotation
    , unknown : Type.Annotation
    , null : Type.Annotation
    , undefined : Type.Annotation
    , void : Type.Annotation
    , naN : Type.Annotation
    }
annotation_ =
    { any =
        Type.alias
            moduleName_
            "Any"
            []
            (Type.namedWith [ "Json", "Encode" ] "Value" [])
    , unknown =
        Type.alias
            moduleName_
            "Unknown"
            []
            (Type.namedWith [ "Json", "Encode" ] "Value" [])
    , null = Type.namedWith [ "Javascript" ] "Null" []
    , undefined = Type.namedWith [ "Javascript" ] "Undefined" []
    , void = Type.namedWith [ "Javascript" ] "Void" []
    , naN = Type.namedWith [ "Javascript" ] "NaN" []
    }


make_ :
    { null : Elm.Expression
    , undefined : Elm.Expression
    , void : Elm.Expression
    , naNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNa :
        Elm.Expression
    }
make_ =
    { null =
        Elm.value
            { importFrom = [ "Javascript" ]
            , name = "Null"
            , annotation = Just (Type.namedWith [ "Javascript" ] "Null" [])
            }
    , undefined =
        Elm.value
            { importFrom = [ "Javascript" ]
            , name = "Undefined"
            , annotation = Just (Type.namedWith [ "Javascript" ] "Undefined" [])
            }
    , void =
        Elm.value
            { importFrom = [ "Javascript" ]
            , name = "Void"
            , annotation = Just (Type.namedWith [ "Javascript" ] "Void" [])
            }
    , naNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNa =
        Elm.value
            { importFrom = [ "Javascript" ]
            , name =
                "NaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNa"
            , annotation = Just (Type.namedWith [ "Javascript" ] "NaN" [])
            }
    }


caseOf_ :
    { null : Elm.Expression -> { null : Elm.Expression } -> Elm.Expression
    , undefined :
        Elm.Expression -> { undefined : Elm.Expression } -> Elm.Expression
    , void : Elm.Expression -> { void : Elm.Expression } -> Elm.Expression
    , naN :
        Elm.Expression
        -> { naNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNa :
            Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { null =
        \nullExpression nullTags ->
            Elm.Case.custom
                nullExpression
                (Type.namedWith [ "Javascript" ] "Null" [])
                [ Elm.Case.branch
                    (Elm.Arg.customType "Null" nullTags.null)
                    Basics.identity
                ]
    , undefined =
        \undefinedExpression undefinedTags ->
            Elm.Case.custom
                undefinedExpression
                (Type.namedWith [ "Javascript" ] "Undefined" [])
                [ Elm.Case.branch
                    (Elm.Arg.customType "Undefined" undefinedTags.undefined)
                    Basics.identity
                ]
    , void =
        \voidExpression voidTags ->
            Elm.Case.custom
                voidExpression
                (Type.namedWith [ "Javascript" ] "Void" [])
                [ Elm.Case.branch
                    (Elm.Arg.customType "Void" voidTags.void)
                    Basics.identity
                ]
    , naN =
        \naNExpression naNTags ->
            Elm.Case.custom
                naNExpression
                (Type.namedWith [ "Javascript" ] "NaN" [])
                [ Elm.Case.branch
                    (Elm.Arg.customType
                       "NaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNa"
                       naNTags.naNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNa
                    )
                    Basics.identity
                ]
    }


call_ :
    { nullEncoder : Elm.Expression -> Elm.Expression
    , undefinedEncoder : Elm.Expression -> Elm.Expression
    , voidEncoder : Elm.Expression -> Elm.Expression
    , nanEncoder : Elm.Expression -> Elm.Expression
    }
call_ =
    { nullEncoder =
        \nullEncoderArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Javascript" ]
                     , name = "nullEncoder"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Javascript" ] "Null" [] ]
                                  (Type.namedWith
                                       [ "Json", "Encode" ]
                                       "Value"
                                       []
                                  )
                             )
                     }
                )
                [ nullEncoderArg_ ]
    , undefinedEncoder =
        \undefinedEncoderArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Javascript" ]
                     , name = "undefinedEncoder"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith
                                      [ "Javascript" ]
                                      "Undefined"
                                      []
                                  ]
                                  (Type.namedWith
                                       [ "Json", "Encode" ]
                                       "Value"
                                       []
                                  )
                             )
                     }
                )
                [ undefinedEncoderArg_ ]
    , voidEncoder =
        \voidEncoderArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Javascript" ]
                     , name = "voidEncoder"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Javascript" ] "Void" [] ]
                                  (Type.namedWith
                                       [ "Json", "Encode" ]
                                       "Value"
                                       []
                                  )
                             )
                     }
                )
                [ voidEncoderArg_ ]
    , nanEncoder =
        \nanEncoderArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Javascript" ]
                     , name = "nanEncoder"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Javascript" ] "NaN" [] ]
                                  (Type.namedWith
                                       [ "Json", "Encode" ]
                                       "Value"
                                       []
                                  )
                             )
                     }
                )
                [ nanEncoderArg_ ]
    }


values_ :
    { nullDecoder : Elm.Expression
    , nullEncoder : Elm.Expression
    , undefinedDecoder : Elm.Expression
    , undefinedEncoder : Elm.Expression
    , voidDecoder : Elm.Expression
    , voidEncoder : Elm.Expression
    , nanDecoder : Elm.Expression
    , nanEncoder : Elm.Expression
    }
values_ =
    { nullDecoder =
        Elm.value
            { importFrom = [ "Javascript" ]
            , name = "nullDecoder"
            , annotation =
                Just
                    (Type.namedWith
                         [ "Json", "Decode" ]
                         "Decoder"
                         [ Type.namedWith [ "Javascript" ] "Null" [] ]
                    )
            }
    , nullEncoder =
        Elm.value
            { importFrom = [ "Javascript" ]
            , name = "nullEncoder"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Javascript" ] "Null" [] ]
                         (Type.namedWith [ "Json", "Encode" ] "Value" [])
                    )
            }
    , undefinedDecoder =
        Elm.value
            { importFrom = [ "Javascript" ]
            , name = "undefinedDecoder"
            , annotation =
                Just
                    (Type.namedWith
                         [ "Json", "Decode" ]
                         "Decoder"
                         [ Type.namedWith [ "Javascript" ] "Undefined" [] ]
                    )
            }
    , undefinedEncoder =
        Elm.value
            { importFrom = [ "Javascript" ]
            , name = "undefinedEncoder"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Javascript" ] "Undefined" [] ]
                         (Type.namedWith [ "Json", "Encode" ] "Value" [])
                    )
            }
    , voidDecoder =
        Elm.value
            { importFrom = [ "Javascript" ]
            , name = "voidDecoder"
            , annotation =
                Just
                    (Type.namedWith
                         [ "Json", "Decode" ]
                         "Decoder"
                         [ Type.namedWith [ "Javascript" ] "Void" [] ]
                    )
            }
    , voidEncoder =
        Elm.value
            { importFrom = [ "Javascript" ]
            , name = "voidEncoder"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Javascript" ] "Void" [] ]
                         (Type.namedWith [ "Json", "Encode" ] "Value" [])
                    )
            }
    , nanDecoder =
        Elm.value
            { importFrom = [ "Javascript" ]
            , name = "nanDecoder"
            , annotation =
                Just
                    (Type.namedWith
                         [ "Json", "Decode" ]
                         "Decoder"
                         [ Type.namedWith [ "Javascript" ] "NaN" [] ]
                    )
            }
    , nanEncoder =
        Elm.value
            { importFrom = [ "Javascript" ]
            , name = "nanEncoder"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Javascript" ] "NaN" [] ]
                         (Type.namedWith [ "Json", "Encode" ] "Value" [])
                    )
            }
    }