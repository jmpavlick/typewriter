module Builder exposing (..)

import Ast exposing (Value(..))
import Dict exposing (Dict)
import Elm
import Elm.Annotation as Type
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
toTypeDecl =
    let
        toTypeAnnotation : Ast.Value -> Result String Type.Annotation
        toTypeAnnotation =
            Result.fromMaybe "No type mapped for this AST value"
                << Ast.optCata typeAnnotationAttrs
                << withCollapsedMaybes
    in
    Result.map (Elm.alias "Value") << toTypeAnnotation



-- DECODERS


decoderExprAttrs : List (Ast.Attr Elm.Expression)
decoderExprAttrs =
    []


toDecoderDecl : Ast.Value -> Result String Elm.Declaration
toDecoderDecl =
    let
        toDecoderExpr : Ast.Value -> Result String Elm.Expression
        toDecoderExpr =
            Result.fromMaybe "Could not create a valid decoder for this type"
                << Ast.optCata decoderExprAttrs
    in
    Result.map (Elm.declaration "decoder") << toDecoderExpr



-- INTERNALS


{-| in typescript, there are (at least?) two ways to represent an optional value:
by allowing something to be nullable, or undefined
naturally, a thing can be _both_ of those things; and while there may be some nuance,
for the sake creating Elm types, it's easier to consider: "okay, is this optional, or not?"

_however_ - this doesn't apply unilaterally - e.g., we don't want our from-Typescript decoders
or to-Typescript encoders to flatten structures that are truly not flat on the other end

which is where having this as an operation separate from the core catamorphism, is quite nice

-}
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
