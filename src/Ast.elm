module Ast exposing
    ( Decl, Value(..)
    , decoder
    , Props, Attr
    , onString, onInt, onFloat, onBool
    , onAny, onUnknown, onVoid, onUndefined, onNull, onNaN
    , onBigInt, onUrl, onIsoTime, onIsoDate, onDateTime
    , onUnimplemented
    , onOptional, onNullable
    , onArray, onRecord, onObject
    , onUnion
    , onNullableOrOptionalFlat, optPara, para
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
    | SRecord Value
    | SObject (Dict String Value)
    | SUnion (Dict String Value)
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
    , sOptional : Value -> a -> a
    , sNullable : Value -> a -> a
    , sArray : Value -> a -> a
    , sRecord : Value -> a -> a
    , sObject : Dict String Value -> Dict String a -> a
    , sUnion : Dict String Value -> Dict String a -> a
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

        SOptional inner ->
            props.sOptional inner (para props inner)

        SNullable inner ->
            props.sNullable inner (para props inner)

        SArray inner ->
            props.sArray inner (para props inner)

        SRecord inner ->
            props.sArray inner (para props inner)

        SObject dict ->
            props.sObject dict (Dict.map (\_ v -> para props v) dict)

        SUnion dict ->
            props.sUnion dict (Dict.map (\_ v -> para props v) dict)

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
            , sOptional = \_ _ -> Nothing
            , sNullable = \_ _ -> Nothing
            , sArray = \_ _ -> Nothing
            , sRecord = \_ _ -> Nothing
            , sObject = \_ _ -> Nothing
            , sUnion = \_ _ -> Nothing
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
onRecord : (Value -> Maybe a -> Maybe a) -> Attr a
onRecord fn base =
    { base | sRecord = fn }


{-| -}
onObject : (Dict String Value -> Dict String (Maybe a) -> Maybe a) -> Attr a
onObject fn base =
    { base | sObject = fn }


{-| -}
onUnion : (Dict String Value -> Dict String (Maybe a) -> Maybe a) -> Attr a
onUnion fn base =
    { base | sUnion = fn }


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

                        "union" ->
                            D.map (\options -> SUnion (Dict.fromList options)) <|
                                D.field "options" <|
                                    D.list
                                        (D.map2 Tuple.pair
                                            (D.oneOf [ D.field "format" D.string, D.field "type" D.string ])
                                            decoder
                                        )

                        _ ->
                            -- eventually we may handle more of zod's types
                            -- just getting us up and moving with MVP for now;
                            -- adding additional handlers will be trivial
                            D.succeed <| SUnimplemented type_
                )
        ]
