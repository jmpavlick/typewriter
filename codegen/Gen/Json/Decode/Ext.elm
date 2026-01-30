module Gen.Json.Decode.Ext exposing ( moduleName_, andMap, call_, values_ )

{-|
# Generated bindings for Json.Decode.Ext

@docs moduleName_, andMap, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Json", "Decode", "Ext" ]


{-| andMap: Json.Decode.Decoder a -> Json.Decode.Decoder (a -> b) -> Json.Decode.Decoder b -}
andMap : Elm.Expression -> Elm.Expression -> Elm.Expression
andMap andMapArg_ andMapArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "Json", "Decode", "Ext" ]
             , name = "andMap"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith
                              [ "Json", "Decode" ]
                              "Decoder"
                              [ Type.var "a" ]
                          , Type.namedWith
                              [ "Json", "Decode" ]
                              "Decoder"
                              [ Type.function [ Type.var "a" ] (Type.var "b") ]
                          ]
                          (Type.namedWith
                               [ "Json", "Decode" ]
                               "Decoder"
                               [ Type.var "b" ]
                          )
                     )
             }
        )
        [ andMapArg_, andMapArg_0 ]


call_ : { andMap : Elm.Expression -> Elm.Expression -> Elm.Expression }
call_ =
    { andMap =
        \andMapArg_ andMapArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Json", "Decode", "Ext" ]
                     , name = "andMap"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith
                                      [ "Json", "Decode" ]
                                      "Decoder"
                                      [ Type.var "a" ]
                                  , Type.namedWith
                                      [ "Json", "Decode" ]
                                      "Decoder"
                                      [ Type.function
                                            [ Type.var "a" ]
                                            (Type.var "b")
                                      ]
                                  ]
                                  (Type.namedWith
                                       [ "Json", "Decode" ]
                                       "Decoder"
                                       [ Type.var "b" ]
                                  )
                             )
                     }
                )
                [ andMapArg_, andMapArg_0 ]
    }


values_ : { andMap : Elm.Expression }
values_ =
    { andMap =
        Elm.value
            { importFrom = [ "Json", "Decode", "Ext" ]
            , name = "andMap"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith
                             [ "Json", "Decode" ]
                             "Decoder"
                             [ Type.var "a" ]
                         , Type.namedWith
                             [ "Json", "Decode" ]
                             "Decoder"
                             [ Type.function [ Type.var "a" ] (Type.var "b") ]
                         ]
                         (Type.namedWith
                              [ "Json", "Decode" ]
                              "Decoder"
                              [ Type.var "b" ]
                         )
                    )
            }
    }