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


{-| best-effort English singular for a generated type name: "UnitGroups" -> "UnitGroup",
"Entries" -> "Entry". words that only look plural ("Address", "Status") pass through on the
"ss"/"us" endings; anything the heuristic mangles still compiles, just reads oddly.
-}
singularize : String -> String
singularize s =
    if String.endsWith "ies" s then
        String.dropRight 3 s ++ "y"

    else if String.endsWith "ss" s || String.endsWith "us" s then
        s

    else if String.endsWith "s" s then
        String.dropRight 1 s

    else
        s


{-| `camelize` collapses [-_ whitespace] into word boundaries but leaves other punctuation
(e.g. the apostrophe in "New Year's Day") intact, which is illegal in an Elm identifier.
Drop anything that isn't a valid identifier char. The decoder matches the original wire
value, so only the constructor *name* is sanitized — never the data.
-}
stripInvalidChars : String -> String
stripInvalidChars =
    String.filter (\c -> Char.isAlphaNum c || c == '_')


toValidIdentifierBase : (Char -> Char) -> String -> Maybe String
toValidIdentifierBase caseFn s =
    case String.uncons <| stripInvalidChars <| String.Extra.camelize s of
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
