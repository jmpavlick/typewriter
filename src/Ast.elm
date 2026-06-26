module Ast exposing
    ( Decl, Value(..)
    , decoder
    , Props, Attr
    , onString, onInt, onFloat, onBool
    , onAny, onUnknown, onVoid, onUndefined, onNull, onNaN
    , onBigInt, onUrl, onIsoTime, onIsoDate, onDateTime
    , onUnimplemented
    , onOptional, onNullable
    , onArray, onTuple, onRecord, onObject
    , onUnion, onDiscriminatedUnion
    , onLiteralBool, onLiteralInt, onLiteralString, onNullableOrOptionalFlat, optPara, para
    )

{-|


# Types

@docs Decl, Value


# JSON

@docs decoder


# The Blessed Paramorphism (calm down it's just a fancy `fold`)

@docs para optPara


# The Glorious F-Algebra (And Its Attribute Band)

@docs Props, Attr


## Attributes


### Leaf Attributes

@docs onString, onInt, onFloat, onBool
@docs onAny, onUnknown, onVoid, onUndefined, onNull, onNaN
@docs onBigInt, onUrl, onIsoTime, onIsoDate, onDateTime
@docs onUnimplemented


### Node Attributes

@docs onOptional, onNullable, onOptionalOrNullableFlat
@docs onArray, onRecord, onObject
@docs onUnion

-}

import Dict exposing (Dict)
import Json.Decode as D exposing (Decoder)
import String.Ext



-- TYPES


{-| -}
type alias Decl =
    ( String, Value )


{-| -}
type Value
    = SString
    | SInt
    | SFloat
    | SBool
    | SAny
    | SUnknown
    | SVoid
    | SUndefined
    | SNull
    | SNaN
    | SUrl
    | SBigInt
    | SIsoTime
    | SIsoDate
    | SDateTime
    | SOptional Value
    | SNullable Value
    | SArray Value
    | STuple (List Value)
    | SRecord Value
    | SObject (Dict String Value)
    | SUnion (Dict String (List Value))
    | SDiscriminatedUnion { discriminator : String, variants : Dict String Value }
    | SLiteralString String
    | SLiteralInt Int
    | SLiteralBool Bool
    | SUnimplemented String


{-| per-variant f-algebras for paramorphism
-}
type alias Props a =
    { sString : a
    , sInt : a
    , sFloat : a
    , sBool : a
    , sAny : a
    , sUnknown : a
    , sVoid : a
    , sUndefined : a
    , sNull : a
    , sNaN : a
    , sBigInt : a
    , sUrl : a
    , sIsoTime : a
    , sIsoDate : a
    , sDateTime : a
    , sLiteralString : String -> a
    , sLiteralInt : Int -> a
    , sLiteralBool : Bool -> a
    , sOptional : Value -> a -> a
    , sNullable : Value -> a -> a
    , sArray : Value -> a -> a
    , sTuple : List Value -> List a -> a
    , sRecord : Value -> a -> a
    , sObject : Dict String Value -> Dict String a -> a
    , sUnion : Dict String (List Value) -> Dict String (List a) -> a
    , sDiscriminatedUnion : { discriminator : String, variants : Dict String Value } -> Dict String a -> a
    , sUnimplemented : String -> a
    }


{-| a paramorphism is just a fold that gives you access to the structure that you're folding over
-}
para : Props a -> Value -> a
para props value =
    case value of
        SString ->
            props.sString

        SInt ->
            props.sInt

        SFloat ->
            props.sFloat

        SBool ->
            props.sBool

        SAny ->
            props.sAny

        SUnknown ->
            props.sUnknown

        SVoid ->
            props.sVoid

        SUndefined ->
            props.sUndefined

        SNull ->
            props.sNull

        SNaN ->
            props.sNaN

        SBigInt ->
            props.sBigInt

        SUrl ->
            props.sUrl

        SIsoTime ->
            props.sIsoTime

        SIsoDate ->
            props.sIsoDate

        SDateTime ->
            props.sDateTime

        SLiteralString s ->
            props.sLiteralString s

        SLiteralInt i ->
            props.sLiteralInt i

        SLiteralBool b ->
            props.sLiteralBool b

        SOptional inner ->
            props.sOptional inner (para props inner)

        SNullable inner ->
            props.sNullable inner (para props inner)

        SArray inner ->
            props.sArray inner (para props inner)

        STuple items ->
            props.sTuple items (List.map (para props) items)

        SRecord inner ->
            props.sRecord inner (para props inner)

        SObject dict ->
            props.sObject dict (Dict.map (\_ v -> para props v) dict)

        SUnion dict ->
            props.sUnion dict (Dict.map (\_ args -> List.map (para props) args) dict)

        SDiscriminatedUnion du ->
            props.sDiscriminatedUnion du (Dict.map (\_ v -> para props v) du.variants)

        SUnimplemented str ->
            props.sUnimplemented str


{-| an attr is a function that modifies the behavior of the f-algebra
for a particular variant of our AST

we expose functions that return props because that's the nice thing to do

-}
type alias Attr a =
    Props (Maybe a) -> Props (Maybe a)


{-| paramorphism but only over whatever properties you specify as caring about
-}
optPara : List (Attr a) -> Value -> Maybe a
optPara attrs =
    let
        base : Props (Maybe a)
        base =
            { sString = Nothing
            , sInt = Nothing
            , sFloat = Nothing
            , sBool = Nothing
            , sAny = Nothing
            , sUnknown = Nothing
            , sVoid = Nothing
            , sUndefined = Nothing
            , sNull = Nothing
            , sNaN = Nothing
            , sBigInt = Nothing
            , sUrl = Nothing
            , sIsoTime = Nothing
            , sIsoDate = Nothing
            , sDateTime = Nothing
            , sLiteralString = \_ -> Nothing
            , sLiteralInt = \_ -> Nothing
            , sLiteralBool = \_ -> Nothing
            , sOptional = \_ _ -> Nothing
            , sNullable = \_ _ -> Nothing
            , sArray = \_ _ -> Nothing
            , sTuple = \_ _ -> Nothing
            , sRecord = \_ _ -> Nothing
            , sObject = \_ _ -> Nothing
            , sUnion = \_ _ -> Nothing
            , sDiscriminatedUnion = \_ _ -> Nothing
            , sUnimplemented = \_ -> Nothing
            }
    in
    para (List.foldl (<|) base attrs)


{-| -}
onString : a -> Attr a
onString value base =
    { base | sString = Just value }


{-| -}
onInt : a -> Attr a
onInt value base =
    { base | sInt = Just value }


{-| -}
onFloat : a -> Attr a
onFloat value base =
    { base | sFloat = Just value }


{-| -}
onBool : a -> Attr a
onBool value base =
    { base | sBool = Just value }


{-| -}
onAny : a -> Attr a
onAny value base =
    { base | sAny = Just value }


{-| -}
onUnknown : a -> Attr a
onUnknown value base =
    { base | sUnknown = Just value }


{-| -}
onVoid : a -> Attr a
onVoid value base =
    { base | sVoid = Just value }


{-| -}
onUndefined : a -> Attr a
onUndefined value base =
    { base | sUndefined = Just value }


{-| -}
onNull : a -> Attr a
onNull value base =
    { base | sNull = Just value }


{-| -}
onNaN : a -> Attr a
onNaN value base =
    { base | sNaN = Just value }


{-| -}
onBigInt : a -> Attr a
onBigInt value base =
    { base | sBigInt = Just value }


{-| -}
onUrl : a -> Attr a
onUrl value base =
    { base | sUrl = Just value }


{-| -}
onIsoTime : a -> Attr a
onIsoTime value base =
    { base | sIsoTime = Just value }


{-| -}
onIsoDate : a -> Attr a
onIsoDate value base =
    { base | sIsoDate = Just value }


{-| -}
onDateTime : a -> Attr a
onDateTime value base =
    { base | sDateTime = Just value }


{-| -}
onLiteralString : (String -> Maybe a) -> Attr a
onLiteralString fn base =
    { base | sLiteralString = fn }


{-| -}
onLiteralInt : (Int -> Maybe a) -> Attr a
onLiteralInt fn base =
    { base | sLiteralInt = fn }


{-| -}
onLiteralBool : (Bool -> Maybe a) -> Attr a
onLiteralBool fn base =
    { base | sLiteralBool = fn }


{-| -}
onOptional : (Value -> Maybe a -> Maybe a) -> Attr a
onOptional fn base =
    { base | sOptional = fn }


{-| -}
onNullable : (Value -> Maybe a -> Maybe a) -> Attr a
onNullable fn base =
    { base | sNullable = fn }


{-| convenience function to make it easier to apply a transformation
to optional / nullable values, without allowing them to nest indefinitely;
in typescript, `prop?: string | null` decodes `"hello"` or `undefined` or `null`
equally as well, but our codegen will create a type and matching decoder
like `prop : Maybe (Maybe String)`, which... sucks.
-}
onNullableOrOptionalFlat : (a -> a) -> Attr a
onNullableOrOptionalFlat fn base =
    let
        flattener : Value -> Maybe a -> Maybe a
        flattener =
            \value maybeA ->
                case value of
                    SOptional _ ->
                        maybeA

                    SNullable _ ->
                        maybeA

                    _ ->
                        Maybe.map fn maybeA
    in
    { base
        | sOptional = flattener
        , sNullable = flattener
    }


{-| -}
onArray : (Value -> Maybe a -> Maybe a) -> Attr a
onArray fn base =
    { base | sArray = fn }


{-| -}
onTuple : (List Value -> List (Maybe a) -> Maybe a) -> Attr a
onTuple fn base =
    { base | sTuple = fn }


{-| -}
onRecord : (Value -> Maybe a -> Maybe a) -> Attr a
onRecord fn base =
    { base | sRecord = fn }


{-| -}
onObject : (Dict String Value -> Dict String (Maybe a) -> Maybe a) -> Attr a
onObject fn base =
    { base | sObject = fn }


{-| -}
onUnion : (Dict String (List Value) -> Dict String (List (Maybe a)) -> Maybe a) -> Attr a
onUnion fn base =
    { base | sUnion = fn }


{-| -}
onDiscriminatedUnion : ({ discriminator : String, variants : Dict String Value } -> Dict String (Maybe a) -> Maybe a) -> Attr a
onDiscriminatedUnion fn base =
    { base | sDiscriminatedUnion = fn }


{-| -}
onUnimplemented : (String -> Maybe a) -> Attr a
onUnimplemented fn base =
    { base | sUnimplemented = fn }



-- JSON


{-| -}
decoder : Decoder Value
decoder =
    D.lazy (always decodeHelp)


decodeHelp : Decoder Value
decodeHelp =
    D.oneOf
        [ D.field "format" D.string
            |> D.andThen
                (\format ->
                    case format of
                        "url" ->
                            D.succeed SUrl

                        "date" ->
                            D.succeed SIsoDate

                        "time" ->
                            D.succeed SIsoTime

                        "datetime" ->
                            -- ISO datetime-formatted string
                            D.succeed SDateTime

                        _ ->
                            D.fail "not covered under the `format` prop; trying other decoders"
                )
        , D.field "type" D.string
            |> D.andThen
                (\type_ ->
                    case type_ of
                        "date" ->
                            -- JavaScript `Date` object
                            D.succeed SDateTime

                        "string" ->
                            D.succeed SString

                        "number" ->
                            D.field "isInt" D.bool
                                |> D.map
                                    (\isInt ->
                                        if isInt then
                                            SInt

                                        else
                                            SFloat
                                    )

                        "boolean" ->
                            D.succeed SBool

                        "any" ->
                            D.succeed SAny

                        "unknown" ->
                            D.succeed SUnknown

                        "void" ->
                            D.succeed SVoid

                        "undefined" ->
                            D.succeed SUndefined

                        "null" ->
                            D.succeed SNull

                        "nan" ->
                            D.succeed SNaN

                        "bigint" ->
                            D.succeed SBigInt

                        "nonoptional" ->
                            D.at [ "def", "innerType", "type" ] D.string
                                |> D.andThen
                                    (\str ->
                                        if str == "optional" then
                                            D.at [ "def", "innerType", "def", "innerType" ] decoder

                                        else
                                            D.fail "Did not expect a `nonoptional` without an `optional` immediately inside"
                                    )

                        "optional" ->
                            D.map SOptional <|
                                D.at [ "def", "innerType" ] decoder

                        "nullable" ->
                            D.map SNullable <|
                                D.at [ "def", "innerType" ] decoder

                        "object" ->
                            D.map SObject <|
                                D.at [ "def", "shape" ] <|
                                    D.dict decoder

                        "record" ->
                            D.andThen
                                (\keyTypeType ->
                                    if keyTypeType == "string" then
                                        D.map SRecord <|
                                            D.at [ "def", "valueType" ] <|
                                                decoder

                                    else
                                        D.fail "Currently, only string-keyed records are supported (sorry, i'll get to it)"
                                )
                                (D.at [ "def", "keyType", "type" ] D.string)

                        "array" ->
                            D.map SArray <|
                                D.field "element" decoder

                        "tuple" ->
                            D.map STuple <|
                                D.at [ "def", "items" ] (D.list decoder)

                        -- `.default(...)` and `.catch(...)` are transparent wrappers: the wire
                        -- value is just the inner type (the default/fallback is a zod-runtime
                        -- concern Elm's decoder doesn't model), so we unwrap to the inner schema.
                        "default" ->
                            D.at [ "def", "innerType" ] decoder

                        "catch" ->
                            D.at [ "def", "innerType" ] decoder

                        "union" ->
                            let
                                -- each option is itself a schema; literal/enum options decode to `SUnion`,
                                -- so a union of literals flattens cleanly into one variant dict.
                                -- object/structural options are kept (positionally keyed) but are not yet
                                -- code-generable — the Builder degrades those to the error module.
                                optionToVariants : Int -> Value -> List ( String, List Value )
                                optionToVariants i option =
                                    case option of
                                        SUnion variants ->
                                            Dict.toList variants

                                        other ->
                                            [ ( "Variant" ++ String.fromInt i, [ other ] ) ]

                                plainUnionDecoder =
                                    D.map
                                        (\options ->
                                            SUnion <|
                                                Dict.fromList <|
                                                    List.concat <|
                                                        List.indexedMap optionToVariants options
                                        )
                                    <|
                                        D.at [ "def", "options" ] (D.list decoder)

                                -- a discriminated union pairs a discriminator field name with object options
                                -- whose discriminant field is a single literal. We key each variant by its
                                -- discriminant wire value and strip the discriminant from the payload.
                                discriminatedUnionDecoder =
                                    D.map2 Tuple.pair
                                        (D.at [ "def", "discriminator" ] D.string)
                                        (D.at [ "def", "options" ] (D.list decoder))
                                        |> D.andThen
                                            (\( discriminator, options ) ->
                                                case extractDiscriminatedVariants discriminator options of
                                                    Just variants ->
                                                        D.succeed <|
                                                            SDiscriminatedUnion
                                                                { discriminator = discriminator
                                                                , variants = variants
                                                                }

                                                    Nothing ->
                                                        D.fail "union has a discriminator but options aren't discriminable objects"
                                            )
                            in
                            -- guard: unsupported union shapes degrade to SUnimplemented rather than
                            -- hard-failing the whole file's decode
                            D.oneOf
                                [ discriminatedUnionDecoder
                                , plainUnionDecoder
                                , D.succeed (SUnimplemented "union (unsupported shape)")
                                ]

                        "enum" ->
                            D.map (\entryDict -> SUnion (Dict.fromList <| List.map (\( _, wire ) -> ( String.Ext.toTypename wire, [ SLiteralString wire ] )) <| Dict.toList entryDict)) <|
                                D.at [ "def", "entries" ] <|
                                    D.dict D.string

                        "literal" ->
                            let
                                -- each literal value yields ( Elm constructor name, [ wire-valued leaf ] );
                                -- the leaf preserves the original value so a matching decoder can be generated
                                variantDecoder =
                                    D.oneOf
                                        [ D.map (\s -> ( String.Ext.toTypename s, [ SLiteralString s ] )) D.string
                                        , D.map (\i -> ( String.Ext.toTypename (String.fromInt i), [ SLiteralInt i ] )) D.int
                                        , D.map
                                            (\v ->
                                                if v then
                                                    ( "LiteralTrue", [ SLiteralBool True ] )

                                                else
                                                    ( "LiteralFalse", [ SLiteralBool False ] )
                                            )
                                            D.bool
                                        ]

                                thisDcdr =
                                    D.map (\variants -> SUnion <| Dict.fromList variants) <|
                                        D.at [ "def", "values" ] (D.list variantDecoder)
                            in
                            thisDcdr

                        _ ->
                            -- eventually we may handle more of zod's types
                            -- just getting us up and moving with MVP for now;
                            -- adding additional handlers will be trivial
                            D.succeed <| SUnimplemented type_
                )
        ]


{-| For a discriminated union, pair each object option with its discriminant wire value
(read from the single-literal discriminator field) and strip that field from the payload.
Returns Nothing if any option isn't a discriminable object, so the caller can degrade.
-}
extractDiscriminatedVariants : String -> List Value -> Maybe (Dict String Value)
extractDiscriminatedVariants discriminator options =
    let
        toEntry : Value -> Maybe ( String, Value )
        toEntry option =
            case option of
                SObject shape ->
                    case Dict.get discriminator shape of
                        Just (SUnion variants) ->
                            case Dict.values variants of
                                [ [ SLiteralString wire ] ] ->
                                    Just ( wire, SObject (Dict.remove discriminator shape) )

                                _ ->
                                    Nothing

                        _ ->
                            Nothing

                _ ->
                    Nothing
    in
    options
        |> List.foldr (\option acc -> Maybe.map2 (::) (toEntry option) acc) (Just [])
        |> Maybe.map Dict.fromList
