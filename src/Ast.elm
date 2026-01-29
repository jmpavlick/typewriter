module Ast exposing
    ( Decl, Value(..)
    , decoder
    , Props, map
    , Attr, optMap, onString, onInt, onFloat, onBool, onOptional, onNullable, onArray, onObject, onUnimplemented
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



-- MAPS


{-| -}
map : Props a -> Value -> a
map props value =
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
type alias Attr a =
    Props (Maybe a) -> Props (Maybe a)


{-| -}
optMap : List (Attr a) -> Value -> Maybe a
optMap attrs =
    let
        base : Props (Maybe a)
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
    map
        (List.foldl (<|) base attrs)


{-| -}
onString : a -> Attr a
onString value base =
    { base | sString = \() -> Just value }


{-| -}
onInt : a -> Attr a
onInt value base =
    { base | sInt = \() -> Just value }


{-| -}
onFloat : a -> Attr a
onFloat value base =
    { base | sFloat = \() -> Just value }


{-| -}
onBool : a -> Attr a
onBool value base =
    { base | sBool = \() -> Just value }


{-| -}
onOptional : (Value -> a) -> Attr a
onOptional fn base =
    { base | sOptional = \v -> Just <| fn v }


{-| -}
onNullable : (Value -> a) -> Attr a
onNullable fn base =
    { base | sNullable = \v -> Just <| fn v }


{-| -}
onArray : (Value -> a) -> Attr a
onArray fn base =
    { base | sArray = \v -> Just <| fn v }


{-| -}
onObject : (Dict String Value -> a) -> Attr a
onObject fn base =
    { base | sObject = \dict -> Just <| fn dict }


{-| -}
onUnimplemented : (String -> a) -> Attr a
onUnimplemented fn base =
    { base | sUnimplemented = \str -> Just <| fn str }



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
