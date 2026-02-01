module Gen.Date.Ext exposing ( moduleName_, decoder, values_ )

{-|
# Generated bindings for Date.Ext

@docs moduleName_, decoder, values_
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


values_ : { decoder : Elm.Expression }
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
    }