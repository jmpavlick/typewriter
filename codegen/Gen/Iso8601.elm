module Gen.Iso8601 exposing
    ( moduleName_, fromTime, toTime, decoder, encode, call_
    , values_
    )

{-|
# Generated bindings for Iso8601

@docs moduleName_, fromTime, toTime, decoder, encode, call_
@docs values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Iso8601" ]


{-| Inflate a Posix integer into a more memory-intensive ISO-8601 date string.

It's generally best to avoid doing this unless an external API requires it.

(UTC integers are less error-prone, take up less memory, and are more efficient
for time arithmetic.)

Format: YYYY-MM-DDTHH:mm:ss.SSSZ

fromTime: Time.Posix -> String
-}
fromTime : Elm.Expression -> Elm.Expression
fromTime fromTimeArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Iso8601" ]
             , name = "fromTime"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Time" ] "Posix" [] ]
                          Type.string
                     )
             }
        )
        [ fromTimeArg_ ]


{-| Convert from an ISO-8601 date string to a `Time.Posix` value.

ISO-8601 date strings sometimes specify things in UTC. Other times, they specify
a non-UTC time as well as a UTC offset. Regardless of which format the ISO-8601
string uses, this function normalizes it and returns a time in UTC.

toTime: String -> Result.Result (List Parser.DeadEnd) Time.Posix
-}
toTime : String -> Elm.Expression
toTime toTimeArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Iso8601" ]
             , name = "toTime"
             , annotation =
                 Just
                     (Type.function
                          [ Type.string ]
                          (Type.namedWith
                               [ "Result" ]
                               "Result"
                               [ Type.list
                                   (Type.namedWith [ "Parser" ] "DeadEnd" [])
                               , Type.namedWith [ "Time" ] "Posix" []
                               ]
                          )
                     )
             }
        )
        [ Elm.string toTimeArg_ ]


{-| Decode an ISO-8601 date string to a `Time.Posix` value using [`toTime`](#toTime).

decoder: Json.Decode.Decoder Time.Posix
-}
decoder : Elm.Expression
decoder =
    Elm.value
        { importFrom = [ "Iso8601" ]
        , name = "decoder"
        , annotation =
            Just
                (Type.namedWith
                     [ "Json", "Decode" ]
                     "Decoder"
                     [ Type.namedWith [ "Time" ] "Posix" [] ]
                )
        }


{-| Encode a `Time.Posix` value as an ISO-8601 date string using
[`fromTime`](#fromTime).

encode: Time.Posix -> Json.Encode.Value
-}
encode : Elm.Expression -> Elm.Expression
encode encodeArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Iso8601" ]
             , name = "encode"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Time" ] "Posix" [] ]
                          (Type.namedWith [ "Json", "Encode" ] "Value" [])
                     )
             }
        )
        [ encodeArg_ ]


call_ :
    { fromTime : Elm.Expression -> Elm.Expression
    , toTime : Elm.Expression -> Elm.Expression
    , encode : Elm.Expression -> Elm.Expression
    }
call_ =
    { fromTime =
        \fromTimeArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Iso8601" ]
                     , name = "fromTime"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Time" ] "Posix" [] ]
                                  Type.string
                             )
                     }
                )
                [ fromTimeArg_ ]
    , toTime =
        \toTimeArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Iso8601" ]
                     , name = "toTime"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.string ]
                                  (Type.namedWith
                                       [ "Result" ]
                                       "Result"
                                       [ Type.list
                                           (Type.namedWith
                                              [ "Parser" ]
                                              "DeadEnd"
                                              []
                                           )
                                       , Type.namedWith [ "Time" ] "Posix" []
                                       ]
                                  )
                             )
                     }
                )
                [ toTimeArg_ ]
    , encode =
        \encodeArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Iso8601" ]
                     , name = "encode"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Time" ] "Posix" [] ]
                                  (Type.namedWith
                                       [ "Json", "Encode" ]
                                       "Value"
                                       []
                                  )
                             )
                     }
                )
                [ encodeArg_ ]
    }


values_ :
    { fromTime : Elm.Expression
    , toTime : Elm.Expression
    , decoder : Elm.Expression
    , encode : Elm.Expression
    }
values_ =
    { fromTime =
        Elm.value
            { importFrom = [ "Iso8601" ]
            , name = "fromTime"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Time" ] "Posix" [] ]
                         Type.string
                    )
            }
    , toTime =
        Elm.value
            { importFrom = [ "Iso8601" ]
            , name = "toTime"
            , annotation =
                Just
                    (Type.function
                         [ Type.string ]
                         (Type.namedWith
                              [ "Result" ]
                              "Result"
                              [ Type.list
                                  (Type.namedWith [ "Parser" ] "DeadEnd" [])
                              , Type.namedWith [ "Time" ] "Posix" []
                              ]
                         )
                    )
            }
    , decoder =
        Elm.value
            { importFrom = [ "Iso8601" ]
            , name = "decoder"
            , annotation =
                Just
                    (Type.namedWith
                         [ "Json", "Decode" ]
                         "Decoder"
                         [ Type.namedWith [ "Time" ] "Posix" [] ]
                    )
            }
    , encode =
        Elm.value
            { importFrom = [ "Iso8601" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Time" ] "Posix" [] ]
                         (Type.namedWith [ "Json", "Encode" ] "Value" [])
                    )
            }
    }