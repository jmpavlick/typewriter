module Generate exposing (main)

{-| -}

import Ast exposing (Value(..))
import Builder
import Dict exposing (Dict)
import Elm
import Elm.Annotation as Type
import Gen.CodeGen.Generate as Generate
import Json.Decode as D
import Json.Encode
import List.Ext


type alias Args =
    { outputModulePath : List String
    , decls : List Ast.Decl
    }


argsDecoder : D.Decoder Args
argsDecoder =
    D.map2 Args
        (D.field "outputModulePath" <| D.list D.string)
        (D.map Dict.toList <| D.field "decls" <| D.dict Ast.decoder)


main : Program Json.Encode.Value () ()
main =
    Generate.fromJson argsDecoder
        (\{ outputModulePath, decls } ->
            List.map (Builder.toFile outputModulePath) decls
        )
