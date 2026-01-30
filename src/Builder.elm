module Builder exposing (..)

import Ast exposing (Value(..))
import Dict exposing (Dict)
import Elm
import Elm.Annotation as Type
import List.Ext
import String.Extra


fold : List (Ast.Attr a) -> Ast.Value -> Maybe a
fold attrs =
    let
        withCollapsedMaybes : Ast.Value -> Ast.Value
        withCollapsedMaybes =
            Ast.cata
                { sString = SString
                , sInt = SInt
                , sFloat = SFloat
                , sBool = SBool
                , sOptional =
                    \inner ->
                        case inner of
                            SOptional _ ->
                                inner

                            SNullable _ ->
                                inner

                            _ ->
                                SOptional inner
                , sNullable =
                    \inner ->
                        case inner of
                            SOptional _ ->
                                inner

                            SNullable _ ->
                                inner

                            _ ->
                                SNullable inner
                , sArray = SArray
                , sObject = SObject
                , sUnimplemented = SUnimplemented
                }
    in
    Ast.optCata attrs << withCollapsedMaybes


toTypeDecl : Ast.Value -> Result String Elm.Declaration
toTypeDecl typedef =
    let
        toTypeAnnotation : () -> Ast.Value -> Result String Type.Annotation
        toTypeAnnotation () =
            Result.fromMaybe "No type mapped for this AST value"
                << fold
                    [ Ast.onString Type.string
                    , Ast.onInt Type.int
                    , Ast.onFloat Type.float
                    , Ast.onBool Type.bool
                    , Ast.onOptional (Maybe.map Type.maybe)
                    , Ast.onNullable (Maybe.map Type.maybe)
                    , Ast.onArray (Maybe.map Type.list)
                    , Ast.onObject
                        (\dict ->
                            dict
                                |> Dict.toList
                                |> List.foldr
                                    (\( k, maybeAnnotation ) acc ->
                                        Maybe.map2 (\annotation rest -> ( k, annotation ) :: rest) maybeAnnotation acc
                                    )
                                    (Just [])
                                |> Maybe.map Type.record
                        )
                    ]
    in
    Result.map (Elm.alias "Value") <| toTypeAnnotation () typedef


build : List String -> Ast.Decl -> ( ( String, List String ), Maybe Elm.File )
build path ( moduleName, typedef ) =
    let
        ( errs, decls ) =
            List.Ext.partitionMapResult identity <|
                List.Ext.concatAp typedef
                    [ toTypeDecl >> List.singleton
                    ]

        buildFile =
            Elm.file (List.map (String.Extra.toTitleCase << String.Extra.camelize) <| List.concat [ path, [ moduleName ] ])
    in
    ( ( moduleName, errs )
    , if List.length decls == 0 then
        Nothing

      else
        Just <| buildFile decls
    )
