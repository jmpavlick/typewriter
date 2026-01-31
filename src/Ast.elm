module Ast exposing
    ( Decl, Value(..)
    , decoder
    , Props
    , Attr, onString, onInt, onFloat, onBool, onAny, onBigInt, onUrl, onOptional, onNullable, onArray, onObject, onUnimplemented
    , onNullableOrOptionalFlat, optPara, para
    )

{-|

@docs Decl, Value
@docs decoder
@docs Props, map
@docs Attr, optMap, onString, onInt, onFloat, onBool, onAny, onBigInt, onUrl, onOptional, onNullable, onOptionalOrNullableFlat, onArray, onObject, onUnimplemented

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
    | SUrl
    | SBigInt
    | SOptional Value
    | SNullable Value
    | SArray Value
    | SObject (Dict String Value)
    | SUnimplemented String


{-| per-variant f-algebras for paramorphism
-}
type alias Props a =
    { sString : a
    , sInt : a
    , sFloat : a
    , sBool : a
    , sAny : a
    , sBigInt : a
    , sUrl : a
    , sOptional : Value -> a -> a
    , sNullable : Value -> a -> a
    , sArray : Value -> a -> a
    , sObject : Dict String Value -> Dict String a -> a

    -- TODO: how to make this open / recursive
    -- maybe `String -> (Maybe (a -> a))`
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

        SBigInt ->
            props.sBigInt

        SUrl ->
            props.sUrl

        SOptional inner ->
            props.sOptional inner (para props inner)

        SNullable inner ->
            props.sNullable inner (para props inner)

        SArray inner ->
            props.sArray inner (para props inner)

        SObject dict ->
            props.sObject dict (Dict.map (\_ v -> para props v) dict)

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
            , sBigInt = Nothing
            , sUrl = Nothing
            , sOptional = \_ _ -> Nothing
            , sNullable = \_ _ -> Nothing
            , sArray = \_ _ -> Nothing
            , sObject = \_ _ -> Nothing
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
onBigInt : a -> Attr a
onBigInt value base =
    { base | sBigInt = Just value }


{-| -}
onUrl : a -> Attr a
onUrl value base =
    { base | sUrl = Just value }


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
onObject : (Dict String Value -> Dict String (Maybe a) -> Maybe a) -> Attr a
onObject fn base =
    { base | sObject = fn }


{-| -}
onUnimplemented : (String -> Maybe a) -> Attr a
onUnimplemented fn base =
    { base | sUnimplemented = fn }



-- JSON


{-| -}
decoder : Decoder Value
decoder =
    D.lazy (always decodeHelp)



-- D.lazy (always justDecodeUrl)


justDecodeUrl : Decoder Value
justDecodeUrl =
    D.oneOf
        [ D.field "format" D.string
            |> D.andThen
                (\format ->
                    case format of
                        "url" ->
                            D.succeed SUrl

                        _ ->
                            D.fail "not covered under the `format` prop; trying other decoders"
                )
        , D.succeed (SUnimplemented "something that isn't a URL")
        ]


decodeHelp : Decoder Value
decodeHelp =
    D.oneOf
        [ D.field "format" D.string
            |> D.andThen
                (\format ->
                    case format of
                        "url" ->
                            D.succeed SUrl

                        _ ->
                            D.fail "not covered under the `format` prop; trying other decoders"
                )
        , D.field "type" D.string
            |> D.andThen
                (\type_ ->
                    case type_ of
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

                        "object" ->
                            D.map SObject <|
                                D.at [ "def", "shape" ] <|
                                    D.dict decoder

                        "boolean" ->
                            D.succeed SBool

                        "any" ->
                            D.succeed SAny

                        "bigint" ->
                            D.succeed SBigInt

                        "optional" ->
                            D.map SOptional <|
                                D.at [ "def", "innerType" ] decoder

                        "nullable" ->
                            D.map SNullable <|
                                D.at [ "def", "innerType" ] decoder

                        "array" ->
                            D.map SArray <|
                                D.field "element" decoder

                        _ ->
                            -- eventually we may handle more of zod's types
                            -- just getting us up and moving with MVP for now;
                            -- adding additional handlers will be trivial
                            D.succeed <| SUnimplemented type_
                )
        ]
