module Ast exposing
    ( Decl, Value(..)
    , decoder
    , Attr, Props, cata, optCata
    , onString, onInt, onFloat, onBool, onOptional, onNullable, onArray, onObject, onUnimplemented
    , onString_deprecated, onInt_deprecated, onFloat_deprecated, onBool_deprecated, onOptional_deprecated, onNullable_deprecated, onArray_deprecated, onObject_deprecated, onUnimplemented_deprecated
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
onString_deprecated : a -> Attr_Deprecated a
onString_deprecated value base =
    { base | sString = \() -> Just value }


{-| -}
onInt_deprecated : a -> Attr_Deprecated a
onInt_deprecated value base =
    { base | sInt = \() -> Just value }


{-| -}
onFloat_deprecated : a -> Attr_Deprecated a
onFloat_deprecated value base =
    { base | sFloat = \() -> Just value }


{-| -}
onBool_deprecated : a -> Attr_Deprecated a
onBool_deprecated value base =
    { base | sBool = \() -> Just value }


{-| -}
onOptional_deprecated : (Value -> Maybe a) -> Attr_Deprecated a
onOptional_deprecated fn base =
    { base | sOptional = \v -> fn v }


{-| -}
onNullable_deprecated : (Value -> Maybe a) -> Attr_Deprecated a
onNullable_deprecated fn base =
    { base | sNullable = \v -> fn v }


{-| -}
onArray_deprecated : (Value -> Maybe a) -> Attr_Deprecated a
onArray_deprecated fn base =
    { base | sArray = \v -> fn v }


{-| -}
onObject_deprecated : (Dict String Value -> Maybe a) -> Attr_Deprecated a
onObject_deprecated fn base =
    { base | sObject = \dict -> fn dict }


{-| -}
onUnimplemented_deprecated : (String -> Maybe a) -> Attr_Deprecated a
onUnimplemented_deprecated fn base =
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
