module Builder exposing (..)

import Ast exposing (Value(..))
import Dict exposing (Dict)
import Elm
import Elm.Annotation as Type
import Elm.Arg
import Elm.Case
import Elm.Ext exposing (pipeline)
import Elm.Op
import Gen.Basics
import Gen.BigInt
import Gen.BigInt.Ext
import Gen.Date
import Gen.Date.Ext
import Gen.Hour
import Gen.Hour.Ext
import Gen.Iso8601
import Gen.Javascript
import Gen.Json.Decode as GD
import Gen.Json.Decode.Extra as GDE
import Gen.Json.Encode as GE
import Gen.Maybe
import Gen.Set
import Gen.Time
import Gen.Tuple
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

                SDiscriminatedUnion du ->
                    -- the root discriminated union becomes `Value` itself; only hoist unions
                    -- nested inside its payloads
                    buildUnionTable <|
                        (Dict.toList du.variants
                            |> List.concatMap (\( wire, payload ) -> collectUnions (String.Ext.toTypename wire) payload)
                        )

                _ ->
                    buildUnionTable <| collectUnions (String.Ext.toTypename moduleName) typedef

        ( typeErrs, typeDecls ) =
            List.Ext.partitionMapResult identity [ toTypeDecl table typedef ]

        ( decoderErrs, decoderDecls ) =
            List.Ext.partitionMapResult identity [ toDecoderDecl table typedef ]

        ( encoderErrs, encoderDecls ) =
            List.Ext.partitionMapResult identity [ toEncoderDecl table typedef ]

        hoisted =
            hoistedUnionDecls table

        buildFile =
            Elm.file (List.map (String.Extra.toTitleCase << String.Extra.camelize) <| List.concat [ path, [ moduleName ] ])
    in
    ( ( moduleName, typeErrs ++ decoderErrs ++ encoderErrs )
    , if List.length (typeDecls ++ decoderDecls) == 0 then
        Nothing

      else
        -- every type and alias up top, every decoder below, every encoder last: the shape
        -- of the data reads as one block without decoder pipelines interleaved
        Just <| buildFile (typeDecls ++ hoisted.types ++ decoderDecls ++ hoisted.decoders ++ encoderDecls ++ hoisted.encoders)
    )



-- TYPE DECLARATIONS


{-| `List (Maybe a) -> Maybe (List a)` — all-or-nothing: every element must be present
-}
sequenceMaybes : List (Maybe a) -> Maybe (List a)
sequenceMaybes =
    List.foldr (Maybe.map2 (::)) (Just [])


{-| right-associate a list into nested pairs via `pair`: [a,b,c,d] -> pair a (pair b (pair c d)).
A single element returns itself; an empty list has no pairing.
-}
rightNestPairs : (a -> a -> a) -> List a -> Maybe a
rightNestPairs pair items =
    case items of
        [] ->
            Nothing

        [ x ] ->
            Just x

        x :: rest ->
            Maybe.map (pair x) (rightNestPairs pair rest)


{-| whether a value's type is usable as an Elm `Set` element / `comparable`
-}
isComparable : Ast.Value -> Bool
isComparable value =
    case value of
        SString ->
            True

        SInt ->
            True

        SFloat ->
            True

        _ ->
            False


typeAnnotationAttrs : UnionTable -> List (Ast.Attr Type.Annotation)
typeAnnotationAttrs table =
    [ -- leaves
      Ast.onString Type.string
    , Ast.onInt Type.int
    , Ast.onFloat Type.float
    , Ast.onBool Type.bool
    , Ast.onAny Gen.Javascript.annotation_.any
    , Ast.onUnknown GD.annotation_.value
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
    , Ast.onTuple
        (\_ items ->
            sequenceMaybes items
                |> Maybe.andThen
                    (\anns ->
                        case anns of
                            [ a, b, c ] ->
                                Just (Type.triple a b c)

                            _ ->
                                -- 2 -> ( a, b ); 4+ -> right-nested pairs ( a, ( b, ( c, d ) ) )
                                rightNestPairs Type.tuple anns
                    )
        )
    , Ast.onSet
        (\inner ->
            -- Elm `Set` requires comparable elements; non-comparable element types degrade
            if isComparable inner then
                Maybe.map Type.set

            else
                always Nothing
        )
    , Ast.onRecord (always (Maybe.map <| Type.dict Type.string))

    -- an enum-keyed record inlines as a record with one field per enum key, each
    -- referencing the hoisted alias for the value type (re-wrapped in `Maybe` when the
    -- value type was optional)
    , Ast.onEnumRecord
        (\keys inner _ ->
            lookupEnumRecordValue table inner
                |> Maybe.map
                    (\( info, optional ) ->
                        let
                            fieldType =
                                if optional then
                                    Type.maybe (Type.named [] info.name)

                                else
                                    Type.named [] info.name
                        in
                        Type.record (List.map (\k -> ( String.Ext.toValidIdentifier k, fieldType )) keys)
                    )
        )
    , Ast.onObject
        (\_ dictOfMaybeAnnotations ->
            dictOfMaybeAnnotations
                |> Dict.toList
                |> List.foldr
                    (\( k, maybeAnnotation ) acc ->
                        -- the WIRE key can be anything JSON allows ("_id"); the Elm field name
                        -- can't. Sanitize the field name only — the decoder still reads the raw
                        -- wire key (see toObjectDecoder), so only the record's spelling changes.
                        Maybe.map2 (\annotation rest -> ( String.Ext.toValidIdentifier k, annotation ) :: rest) maybeAnnotation acc
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
    , Ast.onDiscriminatedUnion
        (\du _ ->
            lookupDiscriminated table du
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


{-| keyed by structural identity so structurally identical unions encountered at different
paths collapse to a single shared declaration
-}
type alias UnionTable =
    Dict String UnionInfo


type alias UnionInfo =
    { name : String, kind : HoistedKind }


{-| the flavors of hoistable named declaration: a payload-free unit union (z.literal/z.enum),
a discriminated union whose variants carry object payloads, or the value type of an
enum-keyed record (hoisted so the inlined record's fields can reference it by name)
-}
type HoistedKind
    = HoistUnit (List UnitVariant)
    | HoistDiscriminated { discriminator : String, variants : Dict String Ast.Value }
    | HoistEnumRecordValue Ast.Value


{-| one collected union awaiting a name, from the pre-pass walk
-}
type alias Collected =
    { key : String, suggested : String, kind : HoistedKind }


{-| canonical structural identity for any AST value, used to key (and dedupe) unions.
mirrors the constructors of Ast.Value
-}
valueKey : Ast.Value -> String
valueKey value =
    case value of
        SString ->
            "str"

        SInt ->
            "int"

        SFloat ->
            "float"

        SBool ->
            "bool"

        SAny ->
            "any"

        SUnknown ->
            "unknown"

        SVoid ->
            "void"

        SUndefined ->
            "undef"

        SNull ->
            "null"

        SNaN ->
            "nan"

        SUrl ->
            "url"

        SBigInt ->
            "bigint"

        SIsoTime ->
            "isotime"

        SIsoDate ->
            "isodate"

        SDateTime ->
            "datetime"

        SOptional inner ->
            "opt(" ++ valueKey inner ++ ")"

        SNullable inner ->
            "nul(" ++ valueKey inner ++ ")"

        SArray inner ->
            "arr(" ++ valueKey inner ++ ")"

        SSet inner ->
            "set(" ++ valueKey inner ++ ")"

        STuple items ->
            "tup(" ++ (List.map valueKey items |> String.join ",") ++ ")"

        SRecord inner ->
            "rec(" ++ valueKey inner ++ ")"

        SEnumRecord keys inner ->
            "rec(" ++ String.join "," keys ++ ";" ++ valueKey inner ++ ")"

        SObject dict ->
            "obj(" ++ (Dict.toList dict |> List.map (\( k, v ) -> k ++ ":" ++ valueKey v) |> String.join ",") ++ ")"

        SUnion variants ->
            "uni(" ++ (Dict.toList variants |> List.map (\( k, vs ) -> k ++ ":" ++ (List.map valueKey vs |> String.join "+")) |> String.join ",") ++ ")"

        SDiscriminatedUnion du ->
            "disc(" ++ du.discriminator ++ ";" ++ (Dict.toList du.variants |> List.map (\( k, v ) -> k ++ ":" ++ valueKey v) |> String.join ",") ++ ")"

        SLiteralString s ->
            "ls:" ++ s

        SLiteralInt i ->
            "li:" ++ String.fromInt i

        SLiteralBool b ->
            "lb:"
                ++ (if b then
                        "t"

                    else
                        "f"
                   )

        SUnimplemented s ->
            "unimpl:" ++ s


{-| structural key for a unit union
-}
unitKey : List UnitVariant -> String
unitKey units =
    "u|" ++ structuralKey units


{-| structural key for a discriminated union
-}
discriminatedKey : { discriminator : String, variants : Dict String Ast.Value } -> String
discriminatedKey du =
    valueKey (SDiscriminatedUnion du)


{-| canonical structural identity for a unit union, independent of where it appears
-}
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


{-| look up the hoisted type for a raw union variant dict, if it classifies as a unit union
-}
lookupUnion : UnionTable -> Dict String (List Ast.Value) -> Maybe UnionInfo
lookupUnion table rawVariants =
    case toUnitUnion rawVariants of
        Ok units ->
            Dict.get (unitKey units) table

        Err _ ->
            Nothing


{-| look up the hoisted type for a discriminated union
-}
lookupDiscriminated : UnionTable -> { discriminator : String, variants : Dict String Ast.Value } -> Maybe UnionInfo
lookupDiscriminated table du =
    Dict.get (discriminatedKey du) table


{-| an enum record's value type, with a `.optional()` wrapper stripped off: the optionality
belongs to the KEYS of the inlined record (each field becomes a `Maybe`), so the hoisted
alias describes the present value
-}
enumRecordValue : Ast.Value -> { optional : Bool, value : Ast.Value }
enumRecordValue inner =
    case inner of
        SOptional v ->
            { optional = True, value = v }

        _ ->
            { optional = False, value = inner }


{-| structural key for an enum record's (unwrapped) value type
-}
enumRecordKey : Ast.Value -> String
enumRecordKey value =
    "erv|" ++ valueKey value


{-| look up the hoisted alias for an enum record's value type, alongside whether the raw
value type was optional (and so must be re-wrapped in `Maybe` at each inlined field)
-}
lookupEnumRecordValue : UnionTable -> Ast.Value -> Maybe ( UnionInfo, Bool )
lookupEnumRecordValue table inner =
    let
        { optional, value } =
            enumRecordValue inner
    in
    Dict.get (enumRecordKey value) table
        |> Maybe.map (\info -> ( info, optional ))


{-| walk the AST collecting every hoistable union (unit or discriminated), carrying a
breadcrumb-derived suggested name (an object field contributes its field name; wrapper nodes
pass through). Returns collected entries in a stable order.
-}
collectUnions : String -> Ast.Value -> List Collected
collectUnions suggested value =
    case value of
        SObject dict ->
            Dict.toList dict
                |> List.concatMap (\( k, v ) -> collectUnions (String.Ext.toTypename k) v)

        SArray inner ->
            collectUnions suggested inner

        SSet inner ->
            collectUnions suggested inner

        STuple items ->
            List.concatMap (collectUnions suggested) items

        SRecord inner ->
            collectUnions suggested inner

        SEnumRecord _ inner ->
            -- register the (unwrapped) value type for hoisting under the breadcrumb name,
            -- then recurse into it so unions nested inside the value are hoisted too
            let
                unwrapped =
                    (enumRecordValue inner).value
            in
            -- the alias names ONE value of the record ("UnitGroup"), while the field
            -- holding the record is naturally plural ("unit_groups") — singularize
            { key = enumRecordKey unwrapped, suggested = String.Ext.singularize suggested, kind = HoistEnumRecordValue unwrapped }
                :: collectUnions suggested unwrapped

        SOptional inner ->
            collectUnions suggested inner

        SNullable inner ->
            collectUnions suggested inner

        SUnion variants ->
            case toUnitUnion variants of
                Ok units ->
                    [ { key = unitKey units, suggested = suggested, kind = HoistUnit units } ]

                Err _ ->
                    -- structural union (not yet code-generable): still recurse into its
                    -- option payloads in case a generatable union is nested deeper
                    Dict.toList variants
                        |> List.concatMap (\( _, args ) -> List.concatMap (collectUnions suggested) args)

        SDiscriminatedUnion du ->
            -- register the discriminated union itself, then recurse into payloads so any
            -- nested unions there (e.g. a z.enum field) are hoisted too
            { key = discriminatedKey du, suggested = suggested, kind = HoistDiscriminated du }
                :: (Dict.toList du.variants
                        |> List.concatMap (\( wire, payload ) -> collectUnions (String.Ext.toTypename wire) payload)
                   )

        _ ->
            []


{-| assign a unique Elm type name to each distinct structural union. structurally identical
unions dedupe to one name; distinct unions that want the same name get a numeric suffix.
-}
buildUnionTable : List Collected -> UnionTable
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
            (\{ key, suggested, kind } ( table, used ) ->
                if Dict.member key table then
                    ( table, used )

                else
                    let
                        name =
                            uniquify suggested used
                    in
                    ( Dict.insert key { name = name, kind = kind } table
                    , Set.insert name used
                    )
            )
            ( Dict.empty, Set.empty )
        |> Tuple.first


{-| the name of a union's generated decoder declaration, e.g. `Group` -> `groupDecoder`
-}
decoderName : String -> String
decoderName typeName =
    String.Ext.toValidIdentifier typeName ++ "Decoder"


{-| the name of a union's generated encoder declaration, e.g. `Group` -> `groupEncoder`
-}
encoderName : String -> String
encoderName typeName =
    String.Ext.toValidIdentifier typeName ++ "Encoder"


{-| Elm custom-type constructors share the module namespace, so two hoisted unions in the
same module that share a variant name (e.g. both have `User`) would collide. We disambiguate
by prefixing each hoisted union's constructors with its type name (`Group` -> `GroupUser`).
Root-level unions are the only type in their module, so they keep clean bare names.
-}
variantCtor : String -> UnitVariant -> String
variantCtor prefix u =
    prefix ++ u.ctor


{-| the `type X = ...` declaration for a unit union
-}
unionTypeDecl : String -> String -> List UnitVariant -> Elm.Declaration
unionTypeDecl name prefix units =
    Elm.customType name (List.map (\u -> Elm.variant (variantCtor prefix u)) units)


{-| hoist every collected nested union to a top-level type + decoder + encoder declaration,
grouped so the file can put all types first, all decoders next, and all encoders last.
Hoisted unions prefix their constructors with the type name to avoid cross-type collisions.
a declaration whose type maps but whose decoder/encoder can't yet be built keeps whatever
subset does.
-}
hoistedUnionDecls : UnionTable -> { types : List Elm.Declaration, decoders : List Elm.Declaration, encoders : List Elm.Declaration }
hoistedUnionDecls table =
    Dict.values table
        |> List.map
            (\{ name, kind } ->
                case kind of
                    HoistUnit units ->
                        { types = [ unionTypeDecl name name units ]
                        , decoders =
                            case unitUnionDecoder name name units of
                                Ok dec ->
                                    [ Elm.declaration (decoderName name) dec ]

                                Err _ ->
                                    []
                        , encoders = [ Elm.declaration (encoderName name) (unitUnionEncoder name name units) ]
                        }

                    HoistDiscriminated du ->
                        case discriminatedUnionTypeDecl table name name du of
                            Ok typeDecl ->
                                { types = [ typeDecl ]
                                , decoders =
                                    case discriminatedUnionDecoder table name name du of
                                        Ok dec ->
                                            [ Elm.declaration (decoderName name) dec ]

                                        Err _ ->
                                            []
                                , encoders =
                                    case discriminatedUnionEncoder table name name du of
                                        Ok enc ->
                                            [ Elm.declaration (encoderName name) enc ]

                                        Err _ ->
                                            []
                                }

                            Err _ ->
                                { types = [], decoders = [], encoders = [] }

                    HoistEnumRecordValue value ->
                        case Ast.optPara (typeAnnotationAttrs table) value of
                            Just ann ->
                                { types = [ Elm.alias name ann ]
                                , decoders =
                                    case Ast.optPara (decoderExprAttrs table) value of
                                        Just dec ->
                                            [ Elm.declaration (decoderName name) <|
                                                Elm.withType (Type.named [] ("Json.Decode.Decoder " ++ name)) dec
                                            ]

                                        Nothing ->
                                            []
                                , encoders =
                                    case Ast.optPara (encoderExprAttrs table) value of
                                        Just node ->
                                            [ Elm.declaration (encoderName name) <|
                                                Elm.withType (Type.function [ Type.named [] name ] jsonValueAnn) node.encoder
                                            ]

                                        Nothing ->
                                            []
                                }

                            Nothing ->
                                { types = [], decoders = [], encoders = [] }
            )
        |> (\groups ->
                { types = List.concatMap .types groups
                , decoders = List.concatMap .decoders groups
                , encoders = List.concatMap .encoders groups
                }
           )



-- DISCRIMINATED UNIONS (z.discriminatedUnion)
-- each variant carries an object payload (the option minus its discriminant field), so unlike
-- unit unions these become `variantWith` constructors and a discriminant-matching decoder.


{-| `type Value = User { ... } | PrivilegedUser { ... }` from a discriminated union
-}
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


{-| `D.field "tag" D.string |> D.andThen (\t -> case t of "user" -> D.map User userDecoder ...)`
-}
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


{-| constructor name for a discriminated variant, from its discriminant wire value
-}
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


{-| Build the decoder for a unit-variant union: read the wire value and emit the matching
constructor. Handles homogeneous string, int, or bool unions; a union mixing wire types
(e.g. a string variant and a number variant) can't share one base decoder and is rejected.
-}
unitUnionDecoder : String -> String -> List UnitVariant -> Result String Elm.Expression
unitUnionDecoder typeName prefix units =
    let
        -- elm-codegen otherwise infers the decoder's type from the last constructor reference
        -- (e.g. `Decoder yellow`); pin it explicitly
        wrap : Elm.Expression -> Elm.Expression
        wrap =
            Elm.withType (Type.named [] ("Json.Decode.Decoder " ++ typeName))

        ctorOf : UnitVariant -> Elm.Expression
        ctorOf u =
            Elm.val (variantCtor prefix u)

        -- `\v -> if v == lit1 then succeed C1 else if v == lit2 ... else fail`, for int/bool
        equalityMatcher : (a -> Elm.Expression) -> List ( UnitVariant, a ) -> Elm.Expression -> Elm.Expression
        equalityMatcher toLit pairs subject =
            List.foldr
                (\( u, lit ) acc -> Elm.ifThen (Elm.Op.equal subject (toLit lit)) (GD.succeed (ctorOf u)) acc)
                (GD.fail ("Unexpected value for " ++ typeName))
                pairs

        pick : (WireValue -> Maybe a) -> List ( UnitVariant, a )
        pick f =
            List.filterMap (\u -> Maybe.map (\a -> ( u, a )) (f u.wire)) units

        strings =
            pick
                (\w ->
                    case w of
                        WireString s ->
                            Just s

                        _ ->
                            Nothing
                )

        ints =
            pick
                (\w ->
                    case w of
                        WireInt i ->
                            Just i

                        _ ->
                            Nothing
                )

        bools =
            pick
                (\w ->
                    case w of
                        WireBool b ->
                            Just b

                        _ ->
                            Nothing
                )

        n =
            List.length units
    in
    if List.length strings == n then
        Ok <|
            wrap <|
                GD.andThen
                    (\s ->
                        Elm.Case.string s
                            { cases = List.map (\( u, sv ) -> ( sv, GD.succeed (ctorOf u) )) strings
                            , otherwise = GD.fail ("Unexpected value for " ++ typeName)
                            }
                    )
                    GD.string

    else if List.length ints == n then
        Ok <| wrap <| GD.andThen (equalityMatcher Elm.int ints) GD.int

    else if List.length bools == n then
        Ok <| wrap <| GD.andThen (equalityMatcher Elm.bool bools) GD.bool

    else
        Err "Mixed-wire union (e.g. string and number literal variants) can't share a single decoder"



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
    , Ast.onTuple
        (\_ items ->
            sequenceMaybes items
                |> Maybe.andThen
                    (\decoders ->
                        let
                            -- read each tuple slot by position
                            indexed =
                                List.indexedMap (\i d -> GD.index i d) decoders

                            pair d1 d2 =
                                GD.map2 (\x y -> Elm.tuple x y) d1 d2
                        in
                        case indexed of
                            [ a, b, c ] ->
                                Just (GD.map3 (\x y z -> Elm.triple x y z) a b c)

                            _ ->
                                rightNestPairs pair indexed
                    )
        )
    , Ast.onSet
        (\inner ->
            if isComparable inner then
                Maybe.map (\d -> GD.map (\listExpr -> Elm.apply Gen.Set.values_.fromList [ listExpr ]) (GD.list d))

            else
                always Nothing
        )
    , Ast.onRecord (\_ innerDecoder -> Maybe.map GD.dict innerDecoder)
    , Ast.onEnumRecord
        (\keys inner _ ->
            lookupEnumRecordValue table inner
                |> Maybe.map (\( info, optional ) -> enumRecordDecoder keys optional info)
        )
    , Ast.onObject
        (\rawFields dictOfMaybeDecoders ->
            dictOfMaybeDecoders
                |> Dict.toList
                |> List.foldr
                    (\( fieldName, maybeDecoder ) acc ->
                        Maybe.map2
                            (\decoder rest ->
                                ( fieldName, fieldKeyIsOptional fieldName rawFields, decoder ) :: rest
                            )
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
    , Ast.onDiscriminatedUnion
        (\du _ ->
            lookupDiscriminated table du
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
                -- pin the root decoder's type: elm-codegen otherwise infers type vars from
                -- lambda arg names for tuple/record constructors (e.g. `Decoder ( unpack, ... )`)
                |> Result.map (Elm.withType (Type.named [] "Json.Decode.Decoder Value"))
                |> Result.map (Elm.declaration "decoder")


{-| is this object field's KEY allowed to be absent? true iff its AST node is `SOptional`
(z's `.optional()`). a `SNullable` (`.nullable()`) field's key must be present but its value
may be null, so it is NOT optional here. the distinction is invisible once the field's value
decoder is built, so we read it straight off the raw AST the paramorphism hands us.
-}
fieldKeyIsOptional : String -> Dict String Value -> Bool
fieldKeyIsOptional name rawFields =
    case Dict.get name rawFields of
        Just (SOptional _) ->
            True

        _ ->
            False


{-| `D.oneOf [ D.field name valueDecoder, D.succeed Nothing ]` — for an OPTIONAL key: an absent
key yields `Nothing`, a present key runs the value decoder (which already tolerates a null value,
being `oneOf [ maybe, nullable ]`). without this a `.optional()` field compiled to a bare
`D.field`, which DEMANDS the key and so failed to decode whenever the key was simply missing.
-}
optionalKeyField : String -> Elm.Expression -> Elm.Expression
optionalKeyField name valueDecoder =
    GD.oneOf
        [ GD.field name valueDecoder
        , GD.succeed Gen.Maybe.make_.nothing
        ]


{-| decoder for an enum-keyed record, targeting the inline Elm record whose fields are the
enum's keys and whose values reference the hoisted value-type decoder. an optional value
type makes every key optional — an absent (or null) key decodes to `Nothing`, mirroring how
`.optional()` object fields are read.
-}
enumRecordDecoder : List String -> Bool -> UnionInfo -> Elm.Expression
enumRecordDecoder keys optional info =
    let
        valueDecoder =
            Elm.val (decoderName info.name)

        fieldDecoder key =
            if optional then
                optionalKeyField key <|
                    GD.oneOf
                        [ GD.maybe valueDecoder
                        , GD.nullable valueDecoder
                        ]

            else
                GD.field key valueDecoder

        ctor =
            Elm.function (List.map (\k -> ( String.Ext.toValidIdentifier k, Nothing )) keys)
                (\argExprs ->
                    Elm.record (List.map2 (\k expr -> ( String.Ext.toValidIdentifier k, expr )) keys argExprs)
                )
    in
    pipeline (GD.succeed ctor) (List.map (\k -> GDE.andMap (fieldDecoder k)) keys)


toObjectDecoder : List ( String, Bool, Elm.Expression ) -> Elm.Expression
toObjectDecoder fields =
    let
        -- Argument specs for the constructor: [("field1", Nothing), ("field2", Nothing)].
        -- lambda args and record keys are ELM identifiers, so they get the sanitized spelling
        -- ("_id" -> "id"); the wire reads below keep the raw key. Must mirror the type-side
        -- sanitization in typeAnnotationAttrs' onObject or the record and its decoder disagree.
        argSpecs : List ( String, Maybe Type.Annotation )
        argSpecs =
            List.map (\( name, _, _ ) -> ( String.Ext.toValidIdentifier name, Nothing )) fields

        -- Build the record constructor: \field1 field2 -> { field1 = field1, field2 = field2 }
        ctor : Elm.Expression
        ctor =
            Elm.function argSpecs
                (\argExprs ->
                    Elm.record
                        (List.map2
                            (\( name, _, _ ) expr -> ( String.Ext.toValidIdentifier name, expr ))
                            fields
                            argExprs
                        )
                )

        -- Build field decoders: [Dx.andMap (D.field "field1" decoder1), ...]. an optional key is
        -- read through `optionalKeyField` so an absent key decodes to `Nothing` instead of failing.
        fieldDecoders : List (Elm.Expression -> Elm.Expression)
        fieldDecoders =
            List.map
                (\( name, keyOptional, decoder ) ->
                    if keyOptional then
                        GDE.andMap (optionalKeyField name decoder)

                    else
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



-- ENCODERS
-- each node built here carries a function `a -> Json.Encode.Value` for the type generated
-- at the same AST node, chosen so that `D.decodeValue decoder (encoder v) == Ok v`


{-| `Json.Encode.Value`, for pinning `encoder : Value -> Json.Encode.Value` annotations
-}
jsonValueAnn : Type.Annotation
jsonValueAnn =
    Type.namedWith [ "Json", "Encode" ] "Value" []


{-| an encoder expression plus the height of its AST node. Elm rejects shadowed names,
and encoder generation nests lambdas (object in object, maybe in object, ...), so every
generated binder is suffixed with its node's height — an ancestor's height is strictly
greater than any descendant's, so nested binders can never collide.
-}
type alias EncoderNode =
    { height : Int, encoder : Elm.Expression }


{-| a leaf encoder: no lambdas of its own, so height 0
-}
leafEnc : Elm.Expression -> EncoderNode
leafEnc expr =
    { height = 0, encoder = expr }


{-| a one-child wrapper that introduces no binder of its own (list/set/dict)
-}
wrapEnc : (Elm.Expression -> Elm.Expression) -> EncoderNode -> EncoderNode
wrapEnc fn node =
    { height = node.height + 1, encoder = fn node.encoder }


{-| binder name for a node of the given height, e.g. `value3`
-}
binder : String -> Int -> String
binder base height =
    base ++ String.fromInt height


encoderExprAttrs : UnionTable -> List (Ast.Attr EncoderNode)
encoderExprAttrs table =
    [ -- leaves
      Ast.onString (leafEnc GE.values_.string)
    , Ast.onInt (leafEnc GE.values_.int)
    , Ast.onFloat (leafEnc GE.values_.float)
    , Ast.onBool (leafEnc GE.values_.bool)

    -- Any/Unknown are already `Json.Encode.Value`
    , Ast.onAny (leafEnc Gen.Basics.values_.identity)
    , Ast.onUnknown (leafEnc Gen.Basics.values_.identity)

    -- the phantom leaves all encode to `null`, which their decoders accept
    , Ast.onVoid (leafEnc Gen.Javascript.values_.voidEncoder)
    , Ast.onUndefined (leafEnc Gen.Javascript.values_.undefinedEncoder)
    , Ast.onNull (leafEnc Gen.Javascript.values_.nullEncoder)
    , Ast.onNaN (leafEnc Gen.Javascript.values_.nanEncoder)
    , Ast.onBigInt (leafEnc Gen.BigInt.Ext.values_.encoder)
    , Ast.onUrl (leafEnc Gen.Url.Ext.values_.encoder)
    , Ast.onDateTime (leafEnc Gen.Iso8601.values_.encode)
    , Ast.onIsoDate (leafEnc Gen.Date.Ext.values_.encoder)
    , Ast.onIsoTime (leafEnc Gen.Hour.Ext.values_.encoder)

    -- nodes
    , Ast.onNullableOrOptionalFlat
        (\node ->
            let
                height =
                    node.height + 1
            in
            { height = height
            , encoder =
                Elm.fn (Elm.Arg.var (binder "maybeValue" height))
                    (\maybeValue ->
                        Elm.Case.maybe maybeValue
                            { nothing = GE.null
                            , just = ( binder "just" height, \just -> Elm.apply node.encoder [ just ] )
                            }
                    )
            }
        )
    , Ast.onArray (\_ -> Maybe.map (wrapEnc (\enc -> Elm.apply GE.values_.list [ enc ])))
    , Ast.onTuple (\_ items -> sequenceMaybes items |> Maybe.andThen tupleEncoder)
    , Ast.onSet
        (\inner ->
            if isComparable inner then
                Maybe.map (wrapEnc (\enc -> Elm.apply GE.values_.set [ enc ]))

            else
                always Nothing
        )
    , Ast.onRecord (\_ -> Maybe.map (wrapEnc (\enc -> Elm.apply GE.values_.dict [ Gen.Basics.values_.identity, enc ])))
    , Ast.onEnumRecord
        (\keys inner _ ->
            lookupEnumRecordValue table inner
                |> Maybe.map (\( info, optional ) -> enumRecordEncoder keys optional info)
        )
    , Ast.onObject
        (\_ dictOfMaybeEncoders ->
            dictOfMaybeEncoders
                |> Dict.toList
                |> List.foldr
                    (\( fieldName, maybeEncoder ) acc ->
                        Maybe.map2
                            (\encoder rest -> ( fieldName, encoder ) :: rest)
                            maybeEncoder
                            acc
                    )
                    (Just [])
                |> Maybe.map toObjectEncoder
        )

    -- a nested unit-variant union encodes via a reference to its hoisted encoder
    , Ast.onUnion
        (\rawVariants _ ->
            lookupUnion table rawVariants
                |> Maybe.map (\info -> leafEnc (Elm.val (encoderName info.name)))
        )
    , Ast.onDiscriminatedUnion
        (\du _ ->
            lookupDiscriminated table du
                |> Maybe.map (\info -> leafEnc (Elm.val (encoderName info.name)))
        )
    ]


toEncoderDecl : UnionTable -> Ast.Value -> Result String Elm.Declaration
toEncoderDecl table value =
    case value of
        SUnion variants ->
            toUnitUnion variants
                |> Result.map (unitUnionEncoder "Value" "")
                |> Result.map (Elm.declaration "encoder")

        SDiscriminatedUnion du ->
            discriminatedUnionEncoder table "Value" "" du
                |> Result.map (Elm.declaration "encoder")

        _ ->
            value
                |> Ast.optPara (encoderExprAttrs table)
                |> Result.fromMaybe "Could not create a valid encoder for this type"
                |> Result.map .encoder
                |> Result.map (Elm.withType (Type.function [ Type.named [] "Value" ] jsonValueAnn))
                |> Result.map (Elm.declaration "encoder")


{-| `\valueN -> E.object [ ( "f1", enc1 valueN.f1 ), ... ]`. the WIRE key stays raw; the
record access uses the sanitized Elm field name, mirroring the type-side sanitization in
typeAnnotationAttrs' onObject.
-}
toObjectEncoder : List ( String, EncoderNode ) -> EncoderNode
toObjectEncoder fields =
    let
        height =
            1 + List.foldl (\( _, node ) acc -> max node.height acc) 0 fields
    in
    { height = height
    , encoder =
        Elm.fn (Elm.Arg.var (binder "value" height))
            (\value ->
                GE.object
                    (List.map
                        (\( fieldName, node ) ->
                            Elm.tuple (Elm.string fieldName) (Elm.apply node.encoder [ Elm.get (String.Ext.toValidIdentifier fieldName) value ])
                        )
                        fields
                    )
            )
    }


{-| encoder for an enum-keyed record: one wire field per enum key, each encoding via the
hoisted value-type encoder. an optional value type means each field is a `Maybe`; `Nothing`
encodes as an explicit `null`, which the paired decoder reads back as `Nothing`.
-}
enumRecordEncoder : List String -> Bool -> UnionInfo -> EncoderNode
enumRecordEncoder keys optional info =
    let
        valueEncoder =
            Elm.val (encoderName info.name)

        -- the hoisted encoder reference is a leaf; the optional wrapper adds a maybe-case
        height =
            if optional then
                2

            else
                1

        fieldValue value key =
            let
                accessed =
                    Elm.get (String.Ext.toValidIdentifier key) value
            in
            if optional then
                Elm.Case.maybe accessed
                    { nothing = GE.null
                    , just = ( binder "just" height, \just -> Elm.apply valueEncoder [ just ] )
                    }

            else
                Elm.apply valueEncoder [ accessed ]
    in
    { height = height
    , encoder =
        Elm.fn (Elm.Arg.var (binder "value" height))
            (\value ->
                GE.object (List.map (\key -> Elm.tuple (Elm.string key) (fieldValue value key)) keys)
            )
    }


{-| the tuple decoder reads a flat JSON array by position (`D.index i`), so the encoder
flattens the Elm shape — `( a, b )`, `( a, b, c )`, or right-nested pairs for 4+ — back
into `E.list identity [ ... ]` in slot order
-}
tupleEncoder : List EncoderNode -> Maybe EncoderNode
tupleEncoder nodes =
    let
        height =
            1 + List.foldl (\node acc -> max node.height acc) 0 nodes

        encodeAll : List EncoderNode -> List Elm.Expression -> Elm.Expression
        encodeAll encs vals =
            GE.call_.list Gen.Basics.values_.identity
                (Elm.list (List.map2 (\node v -> Elm.apply node.encoder [ v ]) encs vals))

        wrap : Elm.Expression -> EncoderNode
        wrap expr =
            { height = height, encoder = expr }
    in
    case nodes of
        [] ->
            Nothing

        [ ea, eb ] ->
            Just <|
                wrap <|
                    Elm.fn (Elm.Arg.tuple (Elm.Arg.var (binder "first" height)) (Elm.Arg.var (binder "second" height)))
                        (\( a, b ) -> encodeAll [ ea, eb ] [ a, b ])

        [ ea, eb, ec ] ->
            Just <|
                wrap <|
                    Elm.fn (Elm.Arg.triple (Elm.Arg.var (binder "first" height)) (Elm.Arg.var (binder "second" height)) (Elm.Arg.var (binder "third" height)))
                        (\( a, b, c ) -> encodeAll [ ea, eb, ec ] [ a, b, c ])

        _ ->
            -- 1 element (a bare value at index 0) or 4+ (right-nested pairs); project slot i
            -- as `Tuple.first (Tuple.second^i value)`, with the final slot just `Tuple.second^i`
            let
                n =
                    List.length nodes
            in
            Just <|
                wrap <|
                    Elm.fn (Elm.Arg.var (binder "value" height))
                        (\value ->
                            let
                                descend : Int -> Elm.Expression -> Elm.Expression
                                descend k expr =
                                    if k <= 0 then
                                        expr

                                    else
                                        descend (k - 1) (Gen.Tuple.second expr)

                                proj : Int -> Elm.Expression
                                proj i =
                                    if i == n - 1 then
                                        descend i value

                                    else
                                        Gen.Tuple.first (descend i value)
                            in
                            encodeAll nodes (List.map proj (List.range 0 (n - 1)))
                        )


{-| `WireString "a"` -> `Json.Encode.string "a"`, etc.
-}
wireEncoder : WireValue -> Elm.Expression
wireEncoder wire =
    case wire of
        WireString s ->
            GE.string s

        WireInt i ->
            GE.int i

        WireBool b ->
            GE.bool b


{-| `\value -> case value of Ctor1 -> E.string "wire1" ...` — the inverse of
`unitUnionDecoder`. Unlike the decoder, this can't fail: every variant's wire value
encodes directly, and mixed-wire unions are fine on the way out.
-}
unitUnionEncoder : String -> String -> List UnitVariant -> Elm.Expression
unitUnionEncoder typeName prefix units =
    Elm.withType (Type.function [ Type.named [] typeName ] jsonValueAnn) <|
        Elm.fn (Elm.Arg.var "value")
            (\value ->
                Elm.Case.custom value
                    (Type.named [] typeName)
                    (List.map
                        (\u ->
                            Elm.Case.branch (Elm.Arg.customType (variantCtor prefix u) ())
                                (\_ -> wireEncoder u.wire)
                        )
                        units
                    )
            )


{-| `\value -> case value of User payload -> E.object (( "tag", E.string "user" ) :: payload fields)` —
re-injects the discriminator the AST stripped, alongside the payload's fields, so the
discriminant-matching decoder roundtrips it.
-}
discriminatedUnionEncoder : UnionTable -> String -> String -> { discriminator : String, variants : Dict String Ast.Value } -> Result String Elm.Expression
discriminatedUnionEncoder table typeName prefix du =
    du.variants
        |> Dict.toList
        |> List.map
            (\( wire, payload ) ->
                (case payload of
                    SObject shape ->
                        shape
                            |> Dict.toList
                            |> List.map
                                (\( fieldName, fieldValue ) ->
                                    Ast.optPara (encoderExprAttrs table) fieldValue
                                        |> Maybe.map (\node -> ( fieldName, node.encoder ))
                                )
                            |> sequenceMaybes

                    _ ->
                        Nothing
                )
                    |> Result.fromMaybe ("Could not build encoder for discriminated variant: " ++ wire)
                    |> Result.map
                        (\fieldEncoders ->
                            Elm.Case.branch
                                (Elm.Arg.customType (discriminantCtor prefix wire) identity
                                    |> Elm.Arg.item (Elm.Arg.var "payload")
                                )
                                (\payloadExpr ->
                                    GE.object
                                        (Elm.tuple (Elm.string du.discriminator) (GE.string wire)
                                            :: List.map
                                                (\( fieldName, enc ) ->
                                                    Elm.tuple (Elm.string fieldName) (Elm.apply enc [ Elm.get (String.Ext.toValidIdentifier fieldName) payloadExpr ])
                                                )
                                                fieldEncoders
                                        )
                                )
                        )
            )
        |> List.foldr (Result.map2 (::)) (Ok [])
        |> Result.map
            (\branches ->
                Elm.withType (Type.function [ Type.named [] typeName ] jsonValueAnn) <|
                    Elm.fn (Elm.Arg.var "value")
                        (\value -> Elm.Case.custom value (Type.named [] typeName) branches)
            )
