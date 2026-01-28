module Shape exposing (..)

import Dict exposing (Dict)
import Json.Decode as D exposing (Decoder)



-- ──────────────────────────────────────────────────────────────
-- Value representation – each constructor represents a **type**
-- ──────────────────────────────────────────────────────────────


type alias Decl =
    ( String, Value )


type Value
    = SString
    | SInt
    | SFloat
    | SBool
    | SUnknown
    | SNull
    | SOptional Value
    | SNullable Value
    | SArray Value
    | SObject (Dict String Value)



-- ──────────────────────────────────────────────────────────────
-- Lazy recursive decoder – produces a Value AST from Zod JSON
-- ──────────────────────────────────────────────────────────────


decoder : Decoder Value
decoder =
    D.lazy (always decodeValue)


decodeValue : Decoder Value
decodeValue =
    D.field "type" D.string
        |> D.andThen decodeByType


decodeByType : String -> Decoder Value
decodeByType typ =
    case typ of
        -- Primitive types -------------------------------------------------
        "string" ->
            D.succeed SString

        "number" ->
            D.succeed SInt

        -- Zod's `int` → SInt, plain `number` → SFloat
        "float" ->
            D.succeed SFloat

        "boolean" ->
            D.succeed SBool

        "null" ->
            D.succeed SNull

        "unknown" ->
            D.succeed SUnknown

        -- Wrapper types ----------------------------------------------------
        "optional" ->
            D.field "innerType" decoder
                |> D.map SOptional

        "nullable" ->
            D.field "innerType" decoder
                |> D.map SNullable

        -- Composite types ---------------------------------------------------
        "array" ->
            D.field "innerType" decoder
                |> D.map SArray

        "object" ->
            D.field "shape" shapeDecoder
                |> D.map SObject

        _ ->
            D.fail ("Unknown Zod type: " ++ typ)



-- Decode a shape (object) into a Dict String Value


shapeDecoder : Decoder (Dict String Value)
shapeDecoder =
    D.dict decoder



-- ──────────────────────────────────────────────────────────────
-- Example usage (the AST you described)
-- ──────────────────────────────────────────────────────────────


sampleObj : Value
sampleObj =
    SObject <|
        Dict.fromList
            [ ( "name", SString )
            , ( "age", SInt )
            , ( "options"
              , SOptional <|
                    SObject <|
                        Dict.fromList
                            [ ( "avatarUrl", SOptional SString )
                            , ( "showSidebar", SOptional SBool )
                            ]
              )
            ]
