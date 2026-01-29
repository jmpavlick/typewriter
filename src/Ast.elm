module Ast exposing (Decl, Props, Value(..), decoder, map, optMap)

import Dict exposing (Dict)
import Json.Decode as D exposing (Decoder)


type alias Decl =
    ( String, Value )


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


type alias Attr a =
    Props (Maybe a) -> Props (Maybe a)


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
