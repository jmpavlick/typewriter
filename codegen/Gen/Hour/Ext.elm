module Gen.Hour.Ext exposing ( moduleName_, decoder, values_ )

{-|
# Generated bindings for Hour.Ext

@docs moduleName_, decoder, values_
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


values_ : { decoder : Elm.Expression }
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
    }