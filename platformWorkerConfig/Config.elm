module Config exposing (..)

import Dict
import Json.Decode
import Json.Decode.Extra
import Json.Encode


type alias Value =
    { elmCodegenConfig :
        { cleanFirst : Bool
        , cwd : String
        , debug : Bool
        , generatorModulePath : String
        , outdir : String
        }
    , relativeGlobalPrepareScriptPath : Maybe String
    , root : String
    , sections :
        Dict.Dict
            String
            { cleanFirst : Maybe Bool
            , debug : Maybe Bool
            , elmCodegenOverrides : Maybe { generatorModulePath : Maybe String }
            , outputModuleNamespace : Maybe (List String)
            , relativeInputPaths : List String
            , relativeOutdir : String
            , relativePrepareScriptPath : Maybe String
            }
    , workdirPath : String
    }


decoder : Json.Decode.Decoder Value
decoder =
    Json.Decode.succeed
        (\elmCodegenConfig relativeGlobalPrepareScriptPath root sections workdirPath ->
            { elmCodegenConfig = elmCodegenConfig
            , relativeGlobalPrepareScriptPath = relativeGlobalPrepareScriptPath
            , root = root
            , sections = sections
            , workdirPath = workdirPath
            }
        )
        |> Json.Decode.Extra.andMap
            (Json.Decode.field
                "elmCodegenConfig"
                (Json.Decode.succeed
                    (\cleanFirst cwd debug generatorModulePath outdir ->
                        { cleanFirst = cleanFirst
                        , cwd = cwd
                        , debug = debug
                        , generatorModulePath =
                            generatorModulePath
                        , outdir = outdir
                        }
                    )
                    |> Json.Decode.Extra.andMap
                        (Json.Decode.field
                            "cleanFirst"
                            Json.Decode.bool
                        )
                    |> Json.Decode.Extra.andMap
                        (Json.Decode.field
                            "cwd"
                            Json.Decode.string
                        )
                    |> Json.Decode.Extra.andMap
                        (Json.Decode.field
                            "debug"
                            Json.Decode.bool
                        )
                    |> Json.Decode.Extra.andMap
                        (Json.Decode.field
                            "generatorModulePath"
                            Json.Decode.string
                        )
                    |> Json.Decode.Extra.andMap
                        (Json.Decode.field
                            "outdir"
                            Json.Decode.string
                        )
                )
            )
        |> Json.Decode.Extra.andMap
            (Json.Decode.oneOf
                [ Json.Decode.field
                    "relativeGlobalPrepareScriptPath"
                    (Json.Decode.oneOf
                        [ Json.Decode.maybe
                            Json.Decode.string
                        , Json.Decode.nullable
                            Json.Decode.string
                        ]
                    )
                , Json.Decode.succeed Nothing
                ]
            )
        |> Json.Decode.Extra.andMap
            (Json.Decode.field
                "root"
                Json.Decode.string
            )
        |> Json.Decode.Extra.andMap
            (Json.Decode.field
                "sections"
                (Json.Decode.dict
                    (Json.Decode.succeed
                        (\cleanFirst debug elmCodegenOverrides outputModuleNamespace relativeInputPaths relativeOutdir relativePrepareScriptPath ->
                            { cleanFirst =
                                cleanFirst
                            , debug =
                                debug
                            , elmCodegenOverrides =
                                elmCodegenOverrides
                            , outputModuleNamespace =
                                outputModuleNamespace
                            , relativeInputPaths =
                                relativeInputPaths
                            , relativeOutdir =
                                relativeOutdir
                            , relativePrepareScriptPath =
                                relativePrepareScriptPath
                            }
                        )
                        |> Json.Decode.Extra.andMap
                            (Json.Decode.oneOf
                                [ Json.Decode.field
                                    "cleanFirst"
                                    (Json.Decode.oneOf
                                        [ Json.Decode.maybe
                                            Json.Decode.bool
                                        , Json.Decode.nullable
                                            Json.Decode.bool
                                        ]
                                    )
                                , Json.Decode.succeed
                                    Nothing
                                ]
                            )
                        |> Json.Decode.Extra.andMap
                            (Json.Decode.oneOf
                                [ Json.Decode.field
                                    "debug"
                                    (Json.Decode.oneOf
                                        [ Json.Decode.maybe
                                            Json.Decode.bool
                                        , Json.Decode.nullable
                                            Json.Decode.bool
                                        ]
                                    )
                                , Json.Decode.succeed
                                    Nothing
                                ]
                            )
                        |> Json.Decode.Extra.andMap
                            (Json.Decode.oneOf
                                [ Json.Decode.field
                                    "elmCodegenOverrides"
                                    (Json.Decode.oneOf
                                        [ Json.Decode.maybe
                                            (Json.Decode.succeed
                                                (\generatorModulePath ->
                                                    { generatorModulePath =
                                                        generatorModulePath
                                                    }
                                                )
                                                |> Json.Decode.Extra.andMap
                                                    (Json.Decode.oneOf
                                                        [ Json.Decode.field
                                                            "generatorModulePath"
                                                            (Json.Decode.oneOf
                                                                [ Json.Decode.maybe
                                                                    Json.Decode.string
                                                                , Json.Decode.nullable
                                                                    Json.Decode.string
                                                                ]
                                                            )
                                                        , Json.Decode.succeed
                                                            Nothing
                                                        ]
                                                    )
                                            )
                                        , Json.Decode.nullable
                                            (Json.Decode.succeed
                                                (\generatorModulePath ->
                                                    { generatorModulePath =
                                                        generatorModulePath
                                                    }
                                                )
                                                |> Json.Decode.Extra.andMap
                                                    (Json.Decode.oneOf
                                                        [ Json.Decode.field
                                                            "generatorModulePath"
                                                            (Json.Decode.oneOf
                                                                [ Json.Decode.maybe
                                                                    Json.Decode.string
                                                                , Json.Decode.nullable
                                                                    Json.Decode.string
                                                                ]
                                                            )
                                                        , Json.Decode.succeed
                                                            Nothing
                                                        ]
                                                    )
                                            )
                                        ]
                                    )
                                , Json.Decode.succeed
                                    Nothing
                                ]
                            )
                        |> Json.Decode.Extra.andMap
                            (Json.Decode.oneOf
                                [ Json.Decode.field
                                    "outputModuleNamespace"
                                    (Json.Decode.oneOf
                                        [ Json.Decode.maybe
                                            (Json.Decode.list
                                                Json.Decode.string
                                            )
                                        , Json.Decode.nullable
                                            (Json.Decode.list
                                                Json.Decode.string
                                            )
                                        ]
                                    )
                                , Json.Decode.succeed
                                    Nothing
                                ]
                            )
                        |> Json.Decode.Extra.andMap
                            (Json.Decode.field
                                "relativeInputPaths"
                                (Json.Decode.list
                                    Json.Decode.string
                                )
                            )
                        |> Json.Decode.Extra.andMap
                            (Json.Decode.field
                                "relativeOutdir"
                                Json.Decode.string
                            )
                        |> Json.Decode.Extra.andMap
                            (Json.Decode.oneOf
                                [ Json.Decode.field
                                    "relativePrepareScriptPath"
                                    (Json.Decode.oneOf
                                        [ Json.Decode.maybe
                                            Json.Decode.string
                                        , Json.Decode.nullable
                                            Json.Decode.string
                                        ]
                                    )
                                , Json.Decode.succeed
                                    Nothing
                                ]
                            )
                    )
                )
            )
        |> Json.Decode.Extra.andMap
            (Json.Decode.field
                "workdirPath"
                Json.Decode.string
            )


encoder : Value -> Json.Encode.Value
encoder value6 =
    Json.Encode.object
        [ ( "elmCodegenConfig"
          , (\value1 ->
                Json.Encode.object
                    [ ( "cleanFirst", Json.Encode.bool value1.cleanFirst )
                    , ( "cwd", Json.Encode.string value1.cwd )
                    , ( "debug", Json.Encode.bool value1.debug )
                    , ( "generatorModulePath"
                      , Json.Encode.string value1.generatorModulePath
                      )
                    , ( "outdir", Json.Encode.string value1.outdir )
                    ]
            )
                value6.elmCodegenConfig
          )
        , ( "relativeGlobalPrepareScriptPath"
          , (\maybeValue1 ->
                case maybeValue1 of
                    Nothing ->
                        Json.Encode.null

                    Just just1 ->
                        Json.Encode.string just1
            )
                value6.relativeGlobalPrepareScriptPath
          )
        , ( "root", Json.Encode.string value6.root )
        , ( "sections"
          , Json.Encode.dict
                Basics.identity
                (\value4 ->
                    Json.Encode.object
                        [ ( "cleanFirst"
                          , (\maybeValue1 ->
                                case maybeValue1 of
                                    Nothing ->
                                        Json.Encode.null

                                    Just just1 ->
                                        Json.Encode.bool just1
                            )
                                value4.cleanFirst
                          )
                        , ( "debug"
                          , (\maybeValue1 ->
                                case maybeValue1 of
                                    Nothing ->
                                        Json.Encode.null

                                    Just just1 ->
                                        Json.Encode.bool just1
                            )
                                value4.debug
                          )
                        , ( "elmCodegenOverrides"
                          , (\maybeValue3 ->
                                case maybeValue3 of
                                    Nothing ->
                                        Json.Encode.null

                                    Just just3 ->
                                        (\value2 ->
                                            Json.Encode.object
                                                [ ( "generatorModulePath"
                                                  , (\maybeValue1 ->
                                                        case maybeValue1 of
                                                            Nothing ->
                                                                Json.Encode.null

                                                            Just just1 ->
                                                                Json.Encode.string
                                                                    just1
                                                    )
                                                        value2.generatorModulePath
                                                  )
                                                ]
                                        )
                                            just3
                            )
                                value4.elmCodegenOverrides
                          )
                        , ( "outputModuleNamespace"
                          , (\maybeValue2 ->
                                case maybeValue2 of
                                    Nothing ->
                                        Json.Encode.null

                                    Just just2 ->
                                        Json.Encode.list Json.Encode.string
                                            just2
                            )
                                value4.outputModuleNamespace
                          )
                        , ( "relativeInputPaths"
                          , Json.Encode.list Json.Encode.string
                                value4.relativeInputPaths
                          )
                        , ( "relativeOutdir"
                          , Json.Encode.string value4.relativeOutdir
                          )
                        , ( "relativePrepareScriptPath"
                          , (\maybeValue1 ->
                                case maybeValue1 of
                                    Nothing ->
                                        Json.Encode.null

                                    Just just1 ->
                                        Json.Encode.string just1
                            )
                                value4.relativePrepareScriptPath
                          )
                        ]
                )
                value6.sections
          )
        , ( "workdirPath", Json.Encode.string value6.workdirPath )
        ]
