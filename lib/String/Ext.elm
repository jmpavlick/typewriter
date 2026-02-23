module String.Ext exposing (..)

import String.Extra


toTypename : String -> String
toTypename s =
    Maybe.withDefault ("Invalid typename: " ++ s) <|
        toValidIdentifierBase Char.toUpper s


toValidIdentifier : String -> String
toValidIdentifier s =
    Maybe.withDefault ("Invalid identifier: " ++ s) <|
        toValidIdentifierBase Char.toLower s


toValidIdentifierBase : (Char -> Char) -> String -> Maybe String
toValidIdentifierBase caseFn s =
    case String.uncons <| String.Extra.camelize s of
        Nothing ->
            Nothing

        Just ( first, rest ) ->
            let
                withLeadingDigitFix ( x, xs ) =
                    if Char.isAlpha x == False then
                        if Char.isDigit x == True then
                            Just ( 'i', "nt_" ++ String.fromChar x ++ xs )

                        else
                            Nothing

                    else
                        Just ( x, xs )

                applyCaseFn ( x, xs ) =
                    Just ( caseFn x, xs )

                fns =
                    [ withLeadingDigitFix
                    , applyCaseFn
                    ]

                res =
                    Maybe.map (\( x, xs ) -> String.cons x xs) <|
                        List.foldl Maybe.andThen
                            (Just ( first, rest ))
                            fns
            in
            res
