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


typeAnnotationAttrs : List (Ast.AttrP Type.Annotation)
typeAnnotationAttrs =
    [ Ast.onStringP Type.string
    , Ast.onIntP Type.int
    , Ast.onFloatP Type.float
    , Ast.onBoolP Type.bool
    , Ast.onOptionalP
        (\( originalInner, maybeAnnotation ) ->
            case originalInner of
                SOptional _ ->
                    maybeAnnotation

                SNullable _ ->
                    maybeAnnotation

                _ ->
                    Maybe.map Type.maybe maybeAnnotation
        )
    , Ast.onNullableP
        (\( originalInner, maybeAnnotation ) ->
            case originalInner of
                SOptional _ ->
                    maybeAnnotation

                SNullable _ ->
                    maybeAnnotation

                _ ->
                    Maybe.map Type.maybe maybeAnnotation
        )
    , Ast.onArrayP (\( _, maybeAnnotation ) -> Maybe.map Type.list maybeAnnotation)
    , Ast.onObjectP
        (\dict ->
            dict
                |> Dict.map (\_ ( _, maybeAnnotation ) -> maybeAnnotation)
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


decoderExprAttrs : List (Ast.AttrP Elm.Expression)
decoderExprAttrs =
    [ Ast.onStringP GD.string
    , Ast.onIntP GD.int
    , Ast.onFloatP GD.float
    , Ast.onBoolP GD.bool
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
