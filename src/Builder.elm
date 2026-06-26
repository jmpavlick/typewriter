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
import Set exposing (Set)
import String.Ext
import String.Extra



-- BUILD AN ELM FILE (or don't)


build : List String -> Ast.Decl -> ( ( String, List String ), Maybe Elm.File )
build path ( moduleName, typedef ) =
    let
        -- pre-pass: name every nested unit-variant union so the traversal can reference it
        -- and so we can hoist its declarations to the top of the module. a root-level union
        -- becomes `Value` itself and is handled separately, so we skip the table for it.
        table : UnionTable
        table =
            case typedef of
                SUnion _ ->
                    Dict.empty

                _ ->
                    buildUnionTable <| collectUnions (String.Ext.toTypename moduleName) typedef

        ( errs, decls ) =
            List.Ext.partitionMapResult identity
                [ toTypeDecl table typedef
                , toDecoderDecl table typedef
                ]

        buildFile =
            Elm.file (List.map (String.Extra.toTitleCase << String.Extra.camelize) <| List.concat [ path, [ moduleName ] ])
    in
    ( ( moduleName, errs )
    , if List.length decls == 0 then
        Nothing

      else
        Just <| buildFile (decls ++ hoistedUnionDecls table)
    )



-- TYPE DECLARATIONS


typeAnnotationAttrs : UnionTable -> List (Ast.Attr Type.Annotation)
typeAnnotationAttrs table =
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

    -- a nested unit-variant union resolves to a reference to its hoisted top-level type
    , Ast.onUnion
        (\rawVariants _ ->
            lookupUnion table rawVariants
                |> Maybe.map (\info -> Type.named [] info.name)
        )
    ]


toTypeDecl : UnionTable -> Ast.Value -> Result String Elm.Declaration
toTypeDecl table value =
    case value of
        -- a union at the root of a decl becomes a custom type named `Value`.
        -- nested unions are hoisted to their own top-level types (see hoistedUnionDecls)
        -- and referenced by name from within this declaration.
        SUnion variants ->
            toUnitUnion variants
                |> Result.map (unionTypeDecl "Value" "")

        SDiscriminatedUnion du ->
            discriminatedUnionTypeDecl table "Value" "" du

        _ ->
            value
                |> Ast.optPara (typeAnnotationAttrs table)
                |> Result.fromMaybe "No type mapped for this AST value"
                |> Result.map (Elm.alias "Value")



-- UNIT-VARIANT UNIONS (z.literal / z.enum / z.union of literals)


type WireValue
    = WireString String
    | WireInt Int
    | WireBool Bool


type alias UnitVariant =
    { ctor : String, wire : WireValue }



-- UNION SYMBOL TABLE
-- a first pass names every nested unit-variant union by its structural identity, so the
-- traversal can reference it and we can hoist its declarations to the top of the module.


{-| keyed by structural identity (sorted variant set) so structurally identical unions
encountered at different paths collapse to a single shared declaration
-}
type alias UnionTable =
    Dict String UnionInfo


type alias UnionInfo =
    { name : String, variants : List UnitVariant }


{-| canonical structural identity for a unit union, independent of where it appears -}
structuralKey : List UnitVariant -> String
structuralKey units =
    units
        |> List.map
            (\u ->
                u.ctor
                    ++ "="
                    ++ (case u.wire of
                            WireString s ->
                                "s:" ++ s

                            WireInt i ->
                                "i:" ++ String.fromInt i

                            WireBool b ->
                                "b:"
                                    ++ (if b then
                                            "true"

                                        else
                                            "false"
                                       )
                       )
            )
        |> List.sort
        |> String.join "|"


{-| look up the hoisted type for a raw union variant dict, if it classifies as a unit union -}
lookupUnion : UnionTable -> Dict String (List Ast.Value) -> Maybe UnionInfo
lookupUnion table rawVariants =
    case toUnitUnion rawVariants of
        Ok units ->
            Dict.get (structuralKey units) table

        Err _ ->
            Nothing


{-| walk the AST collecting every nested unit-variant union, carrying a breadcrumb-derived
suggested name (an object field contributes its field name; wrapper nodes pass through).
Returns (structuralKey, suggestedName, variants) in a stable order.
-}
collectUnions : String -> Ast.Value -> List ( String, String, List UnitVariant )
collectUnions suggested value =
    case value of
        SObject dict ->
            Dict.toList dict
                |> List.concatMap (\( k, v ) -> collectUnions (String.Ext.toTypename k) v)

        SArray inner ->
            collectUnions suggested inner

        SRecord inner ->
            collectUnions suggested inner

        SOptional inner ->
            collectUnions suggested inner

        SNullable inner ->
            collectUnions suggested inner

        SUnion variants ->
            case toUnitUnion variants of
                Ok units ->
                    [ ( structuralKey units, suggested, units ) ]

                Err _ ->
                    -- structural union (not yet code-generable): still recurse into its
                    -- option payloads in case a generatable union is nested deeper
                    Dict.toList variants
                        |> List.concatMap (\( _, args ) -> List.concatMap (collectUnions suggested) args)

        SDiscriminatedUnion du ->
            -- recurse into each variant payload so nested unions there (e.g. a z.enum field)
            -- still get hoisted; the discriminated union itself is generated inline for now
            Dict.toList du.variants
                |> List.concatMap (\( wire, payload ) -> collectUnions (String.Ext.toTypename wire) payload)

        _ ->
            []


{-| assign a unique Elm type name to each distinct structural union. structurally identical
unions dedupe to one name; distinct unions that want the same name get a numeric suffix.
-}
buildUnionTable : List ( String, String, List UnitVariant ) -> UnionTable
buildUnionTable collected =
    let
        uniquify : String -> Set String -> String
        uniquify base used =
            let
                go n =
                    let
                        candidate =
                            base ++ "_" ++ String.fromInt n
                    in
                    if Set.member candidate used then
                        go (n + 1)

                    else
                        candidate
            in
            if Set.member base used then
                go 2

            else
                base
    in
    collected
        |> List.foldl
            (\( key, suggested, units ) ( table, used ) ->
                if Dict.member key table then
                    ( table, used )

                else
                    let
                        name =
                            uniquify suggested used
                    in
                    ( Dict.insert key { name = name, variants = units } table
                    , Set.insert name used
                    )
            )
            ( Dict.empty, Set.empty )
        |> Tuple.first


{-| the name of a union's generated decoder declaration, e.g. `Group` -> `groupDecoder` -}
decoderName : String -> String
decoderName typeName =
    String.Ext.toValidIdentifier typeName ++ "Decoder"


{-| Elm custom-type constructors share the module namespace, so two hoisted unions in the
same module that share a variant name (e.g. both have `User`) would collide. We disambiguate
by prefixing each hoisted union's constructors with its type name (`Group` -> `GroupUser`).
Root-level unions are the only type in their module, so they keep clean bare names.
-}
variantCtor : String -> UnitVariant -> String
variantCtor prefix u =
    prefix ++ u.ctor


{-| the `type X = ...` declaration for a unit union -}
unionTypeDecl : String -> String -> List UnitVariant -> Elm.Declaration
unionTypeDecl name prefix units =
    Elm.customType name (List.map (\u -> Elm.variant (variantCtor prefix u)) units)


{-| hoist every collected nested union to a top-level type + decoder declaration -}
hoistedUnionDecls : UnionTable -> List Elm.Declaration
hoistedUnionDecls table =
    Dict.values table
        |> List.concatMap
            (\info ->
                case unitUnionDecoder info.name info.name info.variants of
                    Ok dec ->
                        [ unionTypeDecl info.name info.name info.variants
                        , Elm.declaration (decoderName info.name) dec
                        ]

                    Err _ ->
                        -- type is still useful even if we can't yet build the decoder
                        [ unionTypeDecl info.name info.name info.variants ]
            )



-- DISCRIMINATED UNIONS (z.discriminatedUnion)
-- each variant carries an object payload (the option minus its discriminant field), so unlike
-- unit unions these become `variantWith` constructors and a discriminant-matching decoder.


{-| `type Value = User { ... } | PrivilegedUser { ... }` from a discriminated union -}
discriminatedUnionTypeDecl : UnionTable -> String -> String -> { discriminator : String, variants : Dict String Ast.Value } -> Result String Elm.Declaration
discriminatedUnionTypeDecl table typeName prefix du =
    du.variants
        |> Dict.toList
        |> List.map
            (\( wire, payload ) ->
                Ast.optPara (typeAnnotationAttrs table) payload
                    |> Result.fromMaybe ("Could not map payload for discriminated variant: " ++ wire)
                    |> Result.map (\ann -> Elm.variantWith (discriminantCtor prefix wire) [ ann ])
            )
        |> List.foldr (Result.map2 (::)) (Ok [])
        |> Result.map (Elm.customType typeName)


{-| `D.field "tag" D.string |> D.andThen (\t -> case t of "user" -> D.map User userDecoder ...)` -}
discriminatedUnionDecoder : UnionTable -> String -> String -> { discriminator : String, variants : Dict String Ast.Value } -> Result String Elm.Expression
discriminatedUnionDecoder table typeName prefix du =
    du.variants
        |> Dict.toList
        |> List.map
            (\( wire, payload ) ->
                Ast.optPara (decoderExprAttrs table) payload
                    |> Result.fromMaybe ("Could not build decoder for discriminated variant: " ++ wire)
                    |> Result.map
                        (\dec ->
                            ( wire
                            , GD.map (\p -> Elm.apply (Elm.val (discriminantCtor prefix wire)) [ p ]) dec
                            )
                        )
            )
        |> List.foldr (Result.map2 (::)) (Ok [])
        |> Result.map
            (\cases ->
                Elm.withType (Type.named [] ("Json.Decode.Decoder " ++ typeName)) <|
                    GD.andThen
                        (\tag ->
                            Elm.Case.string tag
                                { cases = cases
                                , otherwise = GD.fail "Unexpected discriminator for this union"
                                }
                        )
                        (GD.field du.discriminator GD.string)
            )


{-| constructor name for a discriminated variant, from its discriminant wire value -}
discriminantCtor : String -> String -> String
discriminantCtor prefix wire =
    prefix ++ String.Ext.toTypename wire


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
unitUnionDecoder : String -> String -> List UnitVariant -> Result String Elm.Expression
unitUnionDecoder typeName prefix units =
    units
        |> List.map
            (\u ->
                case u.wire of
                    WireString s ->
                        Ok ( s, GD.succeed (Elm.val (variantCtor prefix u)) )

                    _ ->
                        Err "Only string-valued unit unions are supported so far (int/bool literal unions are a future step)"
            )
        |> List.foldr (Result.map2 (::)) (Ok [])
        |> Result.map
            (\cases ->
                -- same "trust me bro" annotation hack as toObjectDecoder: elm-codegen otherwise
                -- infers the decoder's type from the last constructor reference (e.g. `Decoder yellow`)
                Elm.withType (Type.named [] ("Json.Decode.Decoder " ++ typeName)) <|
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


decoderExprAttrs : UnionTable -> List (Ast.Attr Elm.Expression)
decoderExprAttrs table =
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

    -- a nested unit-variant union decodes via a reference to its hoisted decoder
    , Ast.onUnion
        (\rawVariants _ ->
            lookupUnion table rawVariants
                |> Maybe.map (\info -> Elm.val (decoderName info.name))
        )
    ]


toDecoderDecl : UnionTable -> Ast.Value -> Result String Elm.Declaration
toDecoderDecl table value =
    case value of
        SUnion variants ->
            toUnitUnion variants
                |> Result.andThen (unitUnionDecoder "Value" "")
                |> Result.map (Elm.declaration "decoder")

        SDiscriminatedUnion du ->
            discriminatedUnionDecoder table "Value" "" du
                |> Result.map (Elm.declaration "decoder")

        _ ->
            value
                |> Ast.optPara (decoderExprAttrs table)
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
