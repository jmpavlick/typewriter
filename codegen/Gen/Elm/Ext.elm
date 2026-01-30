module Gen.Elm.Ext exposing ( moduleName_, pipeline, call_, values_ )

{-|
# Generated bindings for Elm.Ext

@docs moduleName_, pipeline, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Elm", "Ext" ]


{-| {-| big up leo
-}

pipeline: Elm.Expression -> List (Elm.Expression -> Elm.Expression) -> Elm.Expression
-}
pipeline : Elm.Expression -> List Elm.Expression -> Elm.Expression
pipeline pipelineArg_ pipelineArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "Elm", "Ext" ]
             , name = "pipeline"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Elm" ] "Expression" []
                          , Type.list
                              (Type.function
                                 [ Type.namedWith [ "Elm" ] "Expression" [] ]
                                 (Type.namedWith [ "Elm" ] "Expression" [])
                              )
                          ]
                          (Type.namedWith [ "Elm" ] "Expression" [])
                     )
             }
        )
        [ pipelineArg_, Elm.list pipelineArg_0 ]


call_ : { pipeline : Elm.Expression -> Elm.Expression -> Elm.Expression }
call_ =
    { pipeline =
        \pipelineArg_ pipelineArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Elm", "Ext" ]
                     , name = "pipeline"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Elm" ] "Expression" []
                                  , Type.list
                                      (Type.function
                                         [ Type.namedWith
                                               [ "Elm" ]
                                               "Expression"
                                               []
                                         ]
                                         (Type.namedWith
                                            [ "Elm" ]
                                            "Expression"
                                            []
                                         )
                                      )
                                  ]
                                  (Type.namedWith [ "Elm" ] "Expression" [])
                             )
                     }
                )
                [ pipelineArg_, pipelineArg_0 ]
    }


values_ : { pipeline : Elm.Expression }
values_ =
    { pipeline =
        Elm.value
            { importFrom = [ "Elm", "Ext" ]
            , name = "pipeline"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Elm" ] "Expression" []
                         , Type.list
                             (Type.function
                                [ Type.namedWith [ "Elm" ] "Expression" [] ]
                                (Type.namedWith [ "Elm" ] "Expression" [])
                             )
                         ]
                         (Type.namedWith [ "Elm" ] "Expression" [])
                    )
            }
    }