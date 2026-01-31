module Gen.Url.Ext exposing ( moduleName_, decoder, values_ )

{-|
# Generated bindings for Url.Ext

@docs moduleName_, decoder, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Url", "Ext" ]


{-| decoder: Json.Decode.Decoder Url.Url -}
decoder : Elm.Expression
decoder =
    Elm.value
        { importFrom = [ "Url", "Ext" ]
        , name = "decoder"
        , annotation =
            Just
                (Type.namedWith
                     [ "Json", "Decode" ]
                     "Decoder"
                     [ Type.namedWith [ "Url" ] "Url" [] ]
                )
        }


values_ : { decoder : Elm.Expression }
values_ =
    { decoder =
        Elm.value
            { importFrom = [ "Url", "Ext" ]
            , name = "decoder"
            , annotation =
                Just
                    (Type.namedWith
                         [ "Json", "Decode" ]
                         "Decoder"
                         [ Type.namedWith [ "Url" ] "Url" [] ]
                    )
            }
    }