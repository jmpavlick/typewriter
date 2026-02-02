module Src.Config.ConfigParams exposing (..)

import Json.Decode
import Json.Decode.Ext


type alias Value =
    { relativeGlobalPrepareScriptPath : Maybe String
    , root : Maybe String
    , sections :
        List { cleanFirst : Maybe Bool
        , debug : Maybe Bool
        , elmCodegenOverrides : Maybe { generatorModulePath : Maybe String }
        , relativeInputPaths : List String
        , relativeOutdir : String
        , relativePrepareScriptPath : Maybe String
        }
    }


decoder : Json.Decode.Decoder Value
decoder =
    Json.Decode.succeed
        (\relativeGlobalPrepareScriptPath root sections ->
             { relativeGlobalPrepareScriptPath = relativeGlobalPrepareScriptPath
             , root = root
             , sections = sections
             }
        ) |> Json.Decode.Ext.andMap
                     (Json.Decode.field
                              "relativeGlobalPrepareScriptPath"
                              (Json.Decode.oneOf
                                       [ Json.Decode.maybe Json.Decode.string
                                       , Json.Decode.nullable Json.Decode.string
                                       ]
                              )
                     ) |> Json.Decode.Ext.andMap
                                  (Json.Decode.field
                                           "root"
                                           (Json.Decode.oneOf
                                                    [ Json.Decode.maybe
                                                        Json.Decode.string
                                                    , Json.Decode.nullable
                                                        Json.Decode.string
                                                    ]
                                           )
                                  ) |> Json.Decode.Ext.andMap
                                               (Json.Decode.field
                                                        "sections"
                                                        (Json.Decode.list
                                                                 (Json.Decode.succeed
                                                                          (\cleanFirst debug elmCodegenOverrides relativeInputPaths relativeOutdir relativePrepareScriptPath ->
                                                                                   { cleanFirst =
                                                                                       cleanFirst
                                                                                   , debug =
                                                                                       debug
                                                                                   , elmCodegenOverrides =
                                                                                       elmCodegenOverrides
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
                                               )