module Ast exposing
    ( Decl, Value(..)
    , decoder
    , onString, onInt, onFloat, onBool, onOptional, onNullable, onArray, onObject, onUnimplemented
    , Attr_Deprecated, Props_Deprecated, map_deprecated, optMap_deprecated
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
type alias Props_Deprecated a =
    { sString : () -> a
    , sInt : () -> a
    , sFloat : () -> a
    , sBool : () -> a
    , sOptional : Value -> a
    , sNullable : Value -> a
    , sArray : Value -> a
    , sObject : Dict String Value -> a
    , sUnimplemented : String -> a
    }


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



-- MAPS


{-| -}
map_deprecated : Props_Deprecated a -> Value -> a
map_deprecated props value =
    case value of
        SString ->
            props.sString ()

        SInt ->
            props.sInt ()

        SFloat ->
            props.sFloat ()

        SBool ->
            props.sBool ()

        SOptional v ->
            props.sOptional v

        SNullable v ->
            props.sNullable v

        SArray v ->
            props.sArray v

        SObject dict ->
            props.sObject dict

        SUnimplemented str ->
            props.sUnimplemented str


{-| -}
type alias Attr_Deprecated a =
    Props_Deprecated (Maybe a) -> Props_Deprecated (Maybe a)


{-| -}
optMap_deprecated : List (Attr_Deprecated a) -> Value -> Maybe a
optMap_deprecated attrs =
    let
        base : Props_Deprecated (Maybe a)
        base =
            { sString = always Nothing
            , sInt = always Nothing
            , sFloat = always Nothing
            , sBool = always Nothing
            , sOptional = always Nothing
            , sNullable = always Nothing
            , sArray = always Nothing
            , sObject = always Nothing
            , sUnimplemented = always Nothing
            }
    in
    map_deprecated
        (List.foldl (<|) base attrs)


{-| -}
onString : a -> Attr_Deprecated a
onString value base =
    { base | sString = \() -> Just value }


{-| -}
onInt : a -> Attr_Deprecated a
onInt value base =
    { base | sInt = \() -> Just value }


{-| -}
onFloat : a -> Attr_Deprecated a
onFloat value base =
    { base | sFloat = \() -> Just value }


{-| -}
onBool : a -> Attr_Deprecated a
onBool value base =
    { base | sBool = \() -> Just value }


{-| -}
onOptional : (Value -> Maybe a) -> Attr_Deprecated a
onOptional fn base =
    { base | sOptional = \v -> fn v }


{-| -}
onNullable : (Value -> Maybe a) -> Attr_Deprecated a
onNullable fn base =
    { base | sNullable = \v -> fn v }


{-| -}
onArray : (Value -> Maybe a) -> Attr_Deprecated a
onArray fn base =
    { base | sArray = \v -> fn v }


{-| -}
onObject : (Dict String Value -> Maybe a) -> Attr_Deprecated a
onObject fn base =
    { base | sObject = \dict -> fn dict }


{-| -}
onUnimplemented : (String -> Maybe a) -> Attr_Deprecated a
onUnimplemented fn base =
    { base | sUnimplemented = \str -> fn str }



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
                        D.succeed <| SUnimplemented type_
            )
