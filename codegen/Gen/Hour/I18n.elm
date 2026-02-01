module Gen.Hour.I18n exposing ( moduleName_, en, values_ )

{-|
# Generated bindings for Hour.I18n

@docs moduleName_, en, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Hour", "I18n" ]


{-| en-US support

en: Hour.Language
-}
en : Elm.Expression
en =
    Elm.value
        { importFrom = [ "Hour", "I18n" ]
        , name = "en"
        , annotation = Just (Type.namedWith [ "Hour" ] "Language" [])
        }


values_ : { en : Elm.Expression }
values_ =
    { en =
        Elm.value
            { importFrom = [ "Hour", "I18n" ]
            , name = "en"
            , annotation = Just (Type.namedWith [ "Hour" ] "Language" [])
            }
    }