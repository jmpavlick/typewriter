module Builder exposing (..)

import Ast exposing (Value(..))
import Dict exposing (Dict)
import Elm
import Elm.Annotation as Type
import Gen.Json.Decode as GD
import List.Ext
import String.Extra



-- BUILD AN ELM FILE (or don't)


build : List String -> Ast.Decl -> ( ( String, List String ), Maybe Elm.File )
build path ( moduleName, typedef ) =
    let
        ( errs, decls ) =
            List.Ext.partitionMapResult identity <|
                List.Ext.concatAp typedef
                    [ toTypeDecl >> List.singleton
                    , toDecoderDecl >> List.singleton
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



-- TYPE DECLARATIONS


typeAnnotationAttrs : List (Ast.Attr Type.Annotation)
typeAnnotationAttrs =
    [ Ast.onString Type.string
    , Ast.onInt Type.int
    , Ast.onFloat Type.float
    , Ast.onBool Type.bool
    , Ast.onOptional
        (\value maybeAnnotation ->
            case value of
                SOptional _ ->
                    maybeAnnotation

                SNullable _ ->
                    maybeAnnotation

                _ ->
                    Maybe.map Type.maybe maybeAnnotation
        )
    , Ast.onNullable
        (\value maybeAnnotation ->
            case value of
                SOptional _ ->
                    maybeAnnotation

                SNullable _ ->
                    maybeAnnotation

                _ ->
                    Maybe.map Type.maybe maybeAnnotation
        )
    , Ast.onArray (always (Maybe.map Type.list))
    , Ast.onObject
        (\_ dictOfMaybeAnnotations ->
            dictOfMaybeAnnotations
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
toTypeDecl =
    let
        toTypeAnnotation : Ast.Value -> Result String Type.Annotation
        toTypeAnnotation =
            Result.fromMaybe "No type mapped for this AST value"
                << Ast.optPara typeAnnotationAttrs
    in
    Result.map (Elm.alias "Value") << toTypeAnnotation



-- DECODERS


decoderExprAttrs : List (Ast.Attr Elm.Expression)
decoderExprAttrs =
    [ Ast.onString GD.string
    , Ast.onInt GD.int
    , Ast.onFloat GD.float
    , Ast.onBool GD.bool
    ]


toDecoderDecl : Ast.Value -> Result String Elm.Declaration
toDecoderDecl =
    let
        toDecoderExpr : Ast.Value -> Result String Elm.Expression
        toDecoderExpr =
            Result.fromMaybe "Could not create a valid decoder for this type"
                << Ast.optPara decoderExprAttrs
    in
    Result.map (Elm.declaration "decoder") << toDecoderExpr
