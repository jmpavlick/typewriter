module Config exposing (..)

import Json.Decode
import Json.Decode.Ext


type alias Value =
    { baseConfigMd5Path : String
    , elmCodegenConfig :
        { cleanFirst : Bool
        , cwd : String
        , debug : Bool
        , generatorModulePath : String
        , outdir : String
        }
    , relativeGlobalPrepareScriptPath : Maybe String
    , root : String
    , sections :
        List { cleanFirst : Maybe Bool
        , debug : Maybe Bool
        , elmCodegenOverrides : Maybe { generatorModulePath : Maybe String }
        , outputModuleNamespace : Maybe (List String)
        , relativeInputPaths : List String
        , relativeOutdir : String
        , relativePrepareScriptPath : Maybe String
        }
    , userConfigParamsPath : String
    , workdirPath : String
    }


decoder : Json.Decode.Decoder Value
decoder =
    Json.Decode.succeed
        (\baseConfigMd5Path elmCodegenConfig relativeGlobalPrepareScriptPath root sections userConfigParamsPath workdirPath ->
             { baseConfigMd5Path = baseConfigMd5Path
             , elmCodegenConfig = elmCodegenConfig
             , relativeGlobalPrepareScriptPath = relativeGlobalPrepareScriptPath
             , root = root
             , sections = sections
             , userConfigParamsPath = userConfigParamsPath
             , workdirPath = workdirPath
             }
        ) |> Json.Decode.Ext.andMap
                     (Json.Decode.field "baseConfigMd5Path" Json.Decode.string
                     ) |> Json.Decode.Ext.andMap
                                  (Json.Decode.field
                                           "elmCodegenConfig"
                                           (Json.Decode.succeed
                                                    (\cleanFirst cwd debug generatorModulePath outdir ->
                                                             { cleanFirst =
                                                                 cleanFirst
                                                             , cwd = cwd
                                                             , debug = debug
                                                             , generatorModulePath =
                                                                 generatorModulePath
                                                             , outdir = outdir
                                                             }
                                                    ) |> Json.Decode.Ext.andMap
                                                                     (Json.Decode.field
                                                                                  "cleanFirst"
                                                                                  Json.Decode.bool
                                                                     ) |> Json.Decode.Ext.andMap
                                                                                      (Json.Decode.field
                                                                                                   "cwd"
                                                                                                   Json.Decode.string
                                                                                      ) |> Json.Decode.Ext.andMap
                                                                                                       (Json.Decode.field
                                                                                                                    "debug"
                                                                                                                    Json.Decode.bool
                                                                                                       ) |> Json.Decode.Ext.andMap
                                                                                                                        (Json.Decode.field
                                                                                                                                     "generatorModulePath"
                                                                                                                                     Json.Decode.string
                                                                                                                        ) |> Json.Decode.Ext.andMap
                                                                                                                                         (Json.Decode.field
                                                                                                                                                      "outdir"
                                                                                                                                                      Json.Decode.string
                                                                                                                                         )
                                           )
                                  ) |> Json.Decode.Ext.andMap
                                               (Json.Decode.field
                                                        "relativeGlobalPrepareScriptPath"
                                                        (Json.Decode.oneOf
                                                                 [ Json.Decode.maybe
                                                                     Json.Decode.string
                                                                 , Json.Decode.nullable
                                                                     Json.Decode.string
                                                                 ]
                                                        )
                                               ) |> Json.Decode.Ext.andMap
                                                            (Json.Decode.field
                                                                     "root"
                                                                     Json.Decode.string
                                                            ) |> Json.Decode.Ext.andMap
                                                                         (Json.Decode.field
                                                                                  "sections"
                                                                                  (Json.Decode.list
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
                                                                                                    ) |> Json.Decode.Ext.andMap
                                                                                                                     (Json.Decode.field
                                                                                                                                  "cleanFirst"
                                                                                                                                  (Json.Decode.oneOf
                                                                                                                                               [ Json.Decode.maybe
                                                                                                                                                   Json.Decode.bool
                                                                                                                                               , Json.Decode.nullable
                                                                                                                                                   Json.Decode.bool
                                                                                                                                               ]
                                                                                                                                  )
                                                                                                                     ) |> Json.Decode.Ext.andMap
                                                                                                                                      (Json.Decode.field
                                                                                                                                                   "debug"
                                                                                                                                                   (Json.Decode.oneOf
                                                                                                                                                                [ Json.Decode.maybe
                                                                                                                                                                    Json.Decode.bool
                                                                                                                                                                , Json.Decode.nullable
                                                                                                                                                                    Json.Decode.bool
                                                                                                                                                                ]
                                                                                                                                                   )
                                                                                                                                      ) |> Json.Decode.Ext.andMap
                                                                                                                                                       (Json.Decode.field
                                                                                                                                                                    "elmCodegenOverrides"
                                                                                                                                                                    (Json.Decode.oneOf
                                                                                                                                                                                 [ Json.Decode.maybe
                                                                                                                                                                                     (Json.Decode.succeed
                                                                                                                                                                                        (\generatorModulePath ->
                                                                                                                                                                                           { generatorModulePath =
                                                                                                                                                                                               generatorModulePath
                                                                                                                                                                                           }
                                                                                                                                                                                        ) |> Json.Decode.Ext.andMap
                                                                                                                                                                                                   (Json.Decode.field
                                                                                                                                                                                                          "generatorModulePath"
                                                                                                                                                                                                          (Json.Decode.oneOf
                                                                                                                                                                                                                 [ Json.Decode.maybe
                                                                                                                                                                                                                       Json.Decode.string
                                                                                                                                                                                                                 , Json.Decode.nullable
                                                                                                                                                                                                                       Json.Decode.string
                                                                                                                                                                                                                 ]
                                                                                                                                                                                                          )
                                                                                                                                                                                                   )
                                                                                                                                                                                     )
                                                                                                                                                                                 , Json.Decode.nullable
                                                                                                                                                                                     (Json.Decode.succeed
                                                                                                                                                                                        (\generatorModulePath ->
                                                                                                                                                                                           { generatorModulePath =
                                                                                                                                                                                               generatorModulePath
                                                                                                                                                                                           }
                                                                                                                                                                                        ) |> Json.Decode.Ext.andMap
                                                                                                                                                                                                   (Json.Decode.field
                                                                                                                                                                                                          "generatorModulePath"
                                                                                                                                                                                                          (Json.Decode.oneOf
                                                                                                                                                                                                                 [ Json.Decode.maybe
                                                                                                                                                                                                                       Json.Decode.string
                                                                                                                                                                                                                 , Json.Decode.nullable
                                                                                                                                                                                                                       Json.Decode.string
                                                                                                                                                                                                                 ]
                                                                                                                                                                                                          )
                                                                                                                                                                                                   )
                                                                                                                                                                                     )
                                                                                                                                                                                 ]
                                                                                                                                                                    )
                                                                                                                                                       ) |> Json.Decode.Ext.andMap
                                                                                                                                                                        (Json.Decode.field
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
                                                                                                                                                                        ) |> Json.Decode.Ext.andMap
                                                                                                                                                                                         (Json.Decode.field
                                                                                                                                                                                                      "relativeInputPaths"
                                                                                                                                                                                                      (Json.Decode.list
                                                                                                                                                                                                                   Json.Decode.string
                                                                                                                                                                                                      )
                                                                                                                                                                                         ) |> Json.Decode.Ext.andMap
                                                                                                                                                                                                          (Json.Decode.field
                                                                                                                                                                                                                       "relativeOutdir"
                                                                                                                                                                                                                       Json.Decode.string
                                                                                                                                                                                                          ) |> Json.Decode.Ext.andMap
                                                                                                                                                                                                                           (Json.Decode.field
                                                                                                                                                                                                                                        "relativePrepareScriptPath"
                                                                                                                                                                                                                                        (Json.Decode.oneOf
                                                                                                                                                                                                                                                     [ Json.Decode.maybe
                                                                                                                                                                                                                                                         Json.Decode.string
                                                                                                                                                                                                                                                     , Json.Decode.nullable
                                                                                                                                                                                                                                                         Json.Decode.string
                                                                                                                                                                                                                                                     ]
                                                                                                                                                                                                                                        )
                                                                                                                                                                                                                           )
                                                                                           )
                                                                                  )
                                                                         ) |> Json.Decode.Ext.andMap
                                                                                      (Json.Decode.field
                                                                                               "userConfigParamsPath"
                                                                                               Json.Decode.string
                                                                                      ) |> Json.Decode.Ext.andMap
                                                                                                   (Json.Decode.field
                                                                                                            "workdirPath"
                                                                                                            Json.Decode.string
                                                                                                   )