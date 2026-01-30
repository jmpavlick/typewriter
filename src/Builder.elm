module Builder exposing (..)

import Ast exposing (Value(..))
import Dict exposing (Dict)
import Elm
import Elm.Annotation as Type
import List.Ext
import String.Extra


collapseOptionals : Ast.Value -> Ast.Value
collapseOptionals value =
    Maybe.withDefault value <|
        Ast.optCata
            [ Ast.onString SString
            , Ast.onInt SInt
            , Ast.onFloat SFloat
            , Ast.onBool SBool
            , Ast.onOptional
                (\maybeInner ->
                    Maybe.andThen
                        (\inner ->
                            case inner of
                                SOptional _ ->
                                    Just inner

                                SNullable _ ->
                                    Just inner

                                _ ->
                                    Just (SOptional inner)
                        )
                        maybeInner
                )
            , Ast.onNullable
                (\maybeInner ->
                    Maybe.andThen
                        (\inner ->
                            case inner of
                                SOptional _ ->
                                    Just inner

                                SNullable _ ->
                                    Just inner

                                _ ->
                                    Just (SNullable inner)
                        )
                        maybeInner
                )
            , Ast.onArray (Maybe.map SArray)
            , Ast.onObject (Maybe.map SObject)
            , Ast.onUnimplemented (Just << SUnimplemented)
            ]
            value


fold : List (Ast.Attr a) -> Ast.Value -> Maybe a
fold attrs =
    Ast.optCata attrs << collapseOptionals


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


toTypeDecl : Ast.Value -> Result String Elm.Declaration
toTypeDecl typedef =
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
