module Builder exposing (..)

import Ast exposing (Value(..))
import Dict exposing (Dict)
import Elm
import Elm.Annotation as Type
import Elm.Ext exposing (pipeline)
import Gen.BigInt
import Gen.Json.Decode as GD
import Gen.Json.Decode.Ext as GDE
import Gen.Json.Encode as GE
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
    , Ast.onAny GE.annotation_.value
    , Ast.onBigint Gen.BigInt.annotation_.bigInt
    , Ast.onNullableOrOptionalFlat Type.maybe
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
    , Ast.onAny GD.value
    , Ast.onBigint <|
        GD.oneOf
            [ GD.map Gen.BigInt.call_.fromInt GD.int

            -- TODO: figure out how to do case exprs in elm-codegen
            ]
    , Ast.onNullableOrOptionalFlat
        (\dec ->
            GD.oneOf
                [ GD.maybe dec
                , GD.nullable dec
                ]
        )
    , Ast.onArray (\_ innerDecoder -> Maybe.map GD.list innerDecoder)
    , Ast.onObject
        (\_ dictOfMaybeDecoders ->
            dictOfMaybeDecoders
                |> Dict.toList
                |> List.foldr
                    (\( fieldName, maybeDecoder ) acc ->
                        Maybe.map2
                            (\decoder rest -> ( fieldName, decoder ) :: rest)
                            maybeDecoder
                            acc
                    )
                    (Just [])
                |> Maybe.map toObjectDecoder
        )
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


toObjectDecoder : List ( String, Elm.Expression ) -> Elm.Expression
toObjectDecoder fields =
    let
        -- Argument specs for the constructor: [("field1", Nothing), ("field2", Nothing)]
        argSpecs : List ( String, Maybe Type.Annotation )
        argSpecs =
            List.map (\( name, _ ) -> ( name, Nothing )) fields

        -- Build the record constructor: \field1 field2 -> { field1 = field1, field2 = field2 }
        ctor : Elm.Expression
        ctor =
            Elm.function argSpecs
                (\argExprs ->
                    Elm.record
                        (List.map2
                            (\( name, _ ) expr -> ( name, expr ))
                            fields
                            argExprs
                        )
                )

        -- Build field decoders: [Dx.andMap (D.field "field1" decoder1), ...]
        fieldDecoders : List (Elm.Expression -> Elm.Expression)
        fieldDecoders =
            List.map
                (\( name, decoder ) ->
                    GDE.andMap (GD.field name decoder)
                )
                fields
    in
    -- hack lol; the type that elm-codegen infers is actually the type of the constructor, bizarrely enough -
    -- probably something to do with an implementation detail of `pipeline` that i don't know about
    -- but if you hit 'em with the ol' "trust me bro", well, the only type we're naming in a module
    -- is called `Value`, this is a `Json.Decode.Decoder` for a type called `Value`, and boy i sure hope
    -- that none of these constants change on us, that'd be a bummer, yeah?
    Elm.withType (Type.named [] "Json.Decode.Decoder Value") <|
        -- D.succeed ctor |> Dx.andMap decoder1 |> Dx.andMap decoder2 ...
        pipeline (GD.succeed ctor) fieldDecoders
