module Ast exposing
    ( Decl, Value(..)
    , decoder
    , Props
    , Attr, onString, onInt, onFloat, onBool, onOptional, onNullable, onArray, onObject, onUnimplemented
    , onNullableOrOptionalFlat, optPara, para
    )

{-|

@docs Decl, Value
@docs decoder
@docs Props, map
@docs Attr, optMap, onString, onInt, onFloat, onBool, onOptional, onNullable, onOptionalOrNullableFlat, onArray, onObject, onUnimplemented

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
    | SOptional Value
    | SNullable Value
    | SArray Value
    | SObject (Dict String Value)
    | SUnimplemented String


{-| Props for paramorphism - handlers receive both original structure and recursed results
-}
type alias Props a =
    { sString : a
    , sInt : a
    , sFloat : a
    , sBool : a
    , sOptional : Value -> a -> a
    , sNullable : Value -> a -> a
    , sArray : Value -> a -> a
    , sObject : Dict String Value -> Dict String a -> a
    , sUnimplemented : String -> a
    }


{-| Paramorphism - fold with access to original structure
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


type alias Attr a =
    Props (Maybe a) -> Props (Maybe a)


{-| Optional paramorphism
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


decodeHelp : Decoder Value
decodeHelp =
    D.field "type" D.string
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
