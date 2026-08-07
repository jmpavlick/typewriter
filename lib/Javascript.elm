module Javascript exposing (..)

{-| a ridiculous module in a ridiculous codebase
-}

import Json.Decode as D exposing (Decoder)
import Json.Encode


{-| louder than god's revolver
, and twice as shiny
-}
type NaN
    = NaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNa


nanEncoder : NaN -> Json.Encode.Value
nanEncoder _ =
    Json.Encode.null


nanDecoder : Decoder NaN
nanDecoder =
    D.oneOf
        [ D.null NaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNa
        , D.andThen
            (\str ->
                if String.toLower str == "nan" then
                    D.succeed NaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNa

                else
                    D.fail "Not a string representation of `NaN`"
            )
            D.string
        ]


type Void
    = Void


voidEncoder : Void -> Json.Encode.Value
voidEncoder _ =
    Json.Encode.null


voidDecoder : Decoder Void
voidDecoder =
    D.succeed Void


type Undefined
    = Undefined


undefinedEncoder : Undefined -> Json.Encode.Value
undefinedEncoder _ =
    Json.Encode.null


undefinedDecoder : Decoder Undefined
undefinedDecoder =
    D.succeed Undefined


type alias Unknown =
    Json.Encode.Value


type alias Any =
    Json.Encode.Value


type Null
    = Null


nullEncoder : Null -> Json.Encode.Value
nullEncoder _ =
    Json.Encode.null


nullDecoder : Decoder Null
nullDecoder =
    D.null Null
