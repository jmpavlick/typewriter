module Ast exposing
    ( Decl, Value(..)
    , decoder
    , Props
    , Attr, onString, onInt, onFloat, onBool, onOptional, onNullable, onArray, onObject, onUnimplemented
    , cata, optCata
    )

{-|

@docs Decl, Value
@docs decoder
@docs Props, map
@docs Attr, optMap, onString, onInt, onFloat, onBool, onOptional, onNullable, onArray, onObject, onUnimplemented

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


{-| -}
type alias Props a =
    { sString : a
    , sInt : a
    , sFloat : a
    , sBool : a
    , sOptional : a -> a
    , sNullable : a -> a
    , sArray : a -> a
    , sObject : Dict String a -> a
    , sUnimplemented : String -> a
    }


{-| -}
cata : Props a -> Value -> a
cata props value =
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
            props.sOptional (cata props inner)

        SNullable inner ->
            props.sNullable (cata props inner)

        SArray inner ->
            props.sArray (cata props inner)

        SObject inner ->
            props.sObject (Dict.map (\_ v -> cata props v) inner)

        SUnimplemented label ->
            props.sUnimplemented label


type alias Attr a =
    Props (Maybe a) -> Props (Maybe a)


{-| -}
optCata : List (Attr a) -> Value -> Maybe a
optCata attrs =
    let
        base : Props (Maybe a)
        base =
            { sString = Nothing
            , sInt = Nothing
            , sFloat = Nothing
            , sBool = Nothing
            , sOptional = always Nothing
            , sNullable = always Nothing
            , sArray = always Nothing
            , sObject = always Nothing
            , sUnimplemented = always Nothing
            }
    in
    cata (List.foldl (<|) base attrs)


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
onOptional : (Maybe a -> Maybe a) -> Attr a
onOptional fn base =
    { base | sOptional = fn }


{-| -}
onNullable : (Maybe a -> Maybe a) -> Attr a
onNullable fn base =
    { base | sNullable = fn }


{-| -}
onArray : (Maybe a -> Maybe a) -> Attr a
onArray fn base =
    { base | sArray = fn }


{-| -}
onObject : (Dict String (Maybe a) -> Maybe a) -> Attr a
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
