module Cat exposing (..)


type Value
    = SString
    | SOptional Value


type alias Props a =
    { sString : a
    , sOptional : a -> a
    }


cata : Props b -> Value -> b
cata props value =
    case value of
        SString
            props.sString

        SOptional inner ->
            props.sOptional (cata props inner)


--

type ValueF a
    = FString
    | FOptional a

type alias PropsF a =
    { fString : a
    , fOptional  : a -> a
    }
