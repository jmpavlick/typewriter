module Builder exposing (..)

import Ast exposing (Value(..))
import Dict exposing (Dict)
import Elm
import Elm.Annotation as Type
import Elm.Case
import Elm.Ext exposing (pipeline)
import Gen.BigInt
import Gen.BigInt.Ext
import Gen.Date
import Gen.Date.Ext
import Gen.Hour
import Gen.Hour.Ext
import Gen.Iso8601
import Gen.Javascript
import Gen.Json.Decode as GD
import Gen.Json.Decode.Ext as GDE
import Gen.Json.Encode as GE
import Gen.Time
import Gen.Url
import Gen.Url.Ext
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
-- pardon the dust


type Fragment
    = Variants (List Elm.Variant)
    | Annotation Type.Annotation


liftAnnotationMap : (Type.Annotation -> Type.Annotation) -> (Fragment -> Fragment)
liftAnnotationMap fn frag =
    case frag of
        -- this should be impossible, but Elm has no GADTs
        -- so our play here is to make the impossible state im--
        --
        -- no wait a minute, what if we have, like
        -- type State = On | Off
        -- type alias Switch { name : String, state : State }
        --
        -- we're going to have to describe a tree for these fucking things aren't we
        --
        -- maybe not
        -- read this convo with miniBill:
        -- https://discord.com/channels/534524278847045633/892059254356332554/1467515610333315276
        --
        Variants _ ->
            Annotation <| Type.named [] "Never"

        Annotation ta ->
            Annotation (fn ta)


liftOptAnnotationMap : (Maybe Type.Annotation -> Maybe Type.Annotation) -> (Maybe Fragment -> Maybe Fragment)
liftOptAnnotationMap fn maybeFrag =
    case maybeFrag of
        Just (Variants _) ->
            Nothing

        Just (Annotation ta) ->
            Maybe.map Annotation (fn (Just ta))

        Nothing ->
            Maybe.map Annotation (fn Nothing)


typeAnnotationAttrs : List (Ast.Attr Type.Annotation)
typeAnnotationAttrs =
    [ -- leaves
      Ast.onString Type.string
    , Ast.onInt Type.int
    , Ast.onFloat Type.float
    , Ast.onBool Type.bool
    , Ast.onAny Gen.Javascript.annotation_.any
    , Ast.onUnknown Gen.Javascript.annotation_.unknown
    , Ast.onVoid Gen.Javascript.annotation_.void
    , Ast.onUndefined Gen.Javascript.annotation_.undefined
    , Ast.onNull Gen.Javascript.annotation_.null
    , Ast.onNaN Gen.Javascript.annotation_.naN
    , Ast.onBigInt Gen.BigInt.annotation_.bigInt
    , Ast.onUrl Gen.Url.annotation_.url
    , Ast.onDateTime Gen.Time.annotation_.posix
    , Ast.onIsoDate Gen.Date.annotation_.date
    , Ast.onIsoTime Gen.Hour.annotation_.time

    -- nodes
    , Ast.onNullableOrOptionalFlat Type.maybe
    , Ast.onArray (always (Maybe.map Type.list))
    , Ast.onRecord (always (Maybe.map <| Type.dict Type.string))
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

    -- , Ast.onUnion
    --     (\_ dictOfMaybeAnnotations ->
    --         let
    --             flat =
    --                 Dict.fromList <|
    --                     Maybe.Extra.values <|
    --                         List.map (\( k, maybeV ) -> Maybe.map (\v -> ( k, v )) maybeV) <|
    --                             Dict.toList dictOfMaybeAnnotations
    --         in
    --         toCustomTypeVariants Nothing flat
    --     )
    ]


toTypeDecl : Ast.Value -> Result String Elm.Declaration
toTypeDecl value =
    case value of
        -- a union at the root of a decl becomes a custom type named `Value`.
        -- nested unions still fall through to `optPara` (and currently degrade to the
        -- error module) — hoisting those to named top-level types is the next step.
        SUnion variants ->
            toUnitUnion variants
                |> Result.map
                    (\units ->
                        Elm.customType "Value"
                            (List.map (\u -> Elm.variant u.ctor) units)
                    )

        _ ->
            value
                |> Ast.optPara typeAnnotationAttrs
                |> Result.fromMaybe "No type mapped for this AST value"
                |> Result.map (Elm.alias "Value")



-- UNIT-VARIANT UNIONS (z.literal / z.enum / z.union of literals)


type WireValue
    = WireString String
    | WireInt Int
    | WireBool Bool


type alias UnitVariant =
    { ctor : String, wire : WireValue }


{-| Classify a union's variant dict as a set of unit (payload-free) variants, recovering
the original wire value for each from the literal leaf preserved during AST decoding.
Fails if any variant carries a structural payload (object/discriminated unions), which
are not yet code-generable.
-}
toUnitUnion : Dict String (List Ast.Value) -> Result String (List UnitVariant)
toUnitUnion variants =
    variants
        |> Dict.toList
        |> List.map
            (\( ctor, args ) ->
                case args of
                    [ SLiteralString s ] ->
                        Ok { ctor = ctor, wire = WireString s }

                    [ SLiteralInt i ] ->
                        Ok { ctor = ctor, wire = WireInt i }

                    [ SLiteralBool b ] ->
                        Ok { ctor = ctor, wire = WireBool b }

                    _ ->
                        Err "Structural/object unions are not supported yet (only z.literal, z.enum, and unions of literals)"
            )
        |> List.foldr (Result.map2 (::)) (Ok [])


{-| Build the decoder for a unit-variant union: match the wire value and emit the
corresponding constructor. Only string-valued unions are supported so far.
-}
unitUnionDecoder : List UnitVariant -> Result String Elm.Expression
unitUnionDecoder units =
    units
        |> List.map
            (\u ->
                case u.wire of
                    WireString s ->
                        Ok ( s, GD.succeed (Elm.val u.ctor) )

                    _ ->
                        Err "Only string-valued unit unions are supported so far (int/bool literal unions are a future step)"
            )
        |> List.foldr (Result.map2 (::)) (Ok [])
        |> Result.map
            (\cases ->
                -- same "trust me bro" annotation hack as toObjectDecoder: elm-codegen otherwise
                -- infers the decoder's type from the last constructor reference (e.g. `Decoder yellow`)
                Elm.withType (Type.named [] "Json.Decode.Decoder Value") <|
                    GD.andThen
                        (\s ->
                            Elm.Case.string s
                                { cases = cases
                                , otherwise = GD.fail "Unexpected value for this union"
                                }
                        )
                        GD.string
            )



-- DECODERS


decoderExprAttrs : List (Ast.Attr Elm.Expression)
decoderExprAttrs =
    [ -- leaves
      Ast.onString GD.string
    , Ast.onInt GD.int
    , Ast.onFloat GD.float
    , Ast.onBool GD.bool
    , Ast.onAny GD.value
    , Ast.onUnknown GD.value
    , Ast.onVoid Gen.Javascript.voidDecoder
    , Ast.onUndefined Gen.Javascript.undefinedDecoder
    , Ast.onNull Gen.Javascript.nullDecoder
    , Ast.onNaN Gen.Javascript.nanDecoder
    , Ast.onBigInt Gen.BigInt.Ext.decoder
    , Ast.onUrl Gen.Url.Ext.decoder
    , Ast.onDateTime Gen.Iso8601.decoder
    , Ast.onIsoDate Gen.Date.Ext.decoder
    , Ast.onIsoTime Gen.Hour.Ext.decoder

    -- nodes
    , Ast.onNullableOrOptionalFlat
        (\dec ->
            GD.oneOf
                [ GD.maybe dec
                , GD.nullable dec
                ]
        )
    , Ast.onArray (\_ innerDecoder -> Maybe.map GD.list innerDecoder)
    , Ast.onRecord (\_ innerDecoder -> Maybe.map GD.dict innerDecoder)
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
toDecoderDecl value =
    case value of
        SUnion variants ->
            toUnitUnion variants
                |> Result.andThen unitUnionDecoder
                |> Result.map (Elm.declaration "decoder")

        _ ->
            value
                |> Ast.optPara decoderExprAttrs
                |> Result.fromMaybe "Could not create a valid decoder for this type"
                |> Result.map (Elm.declaration "decoder")


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
