module Generate exposing (main)

{-| -}

import Ast exposing (Value(..))
import Elm
import Elm.Annotation as Type
import Gen.CodeGen.Generate as Generate
import Json.Decode as D
import Json.Encode


main : Program Json.Encode.Value () ()
main =
    Generate.fromJson (D.dict Ast.decoder)
        (\decls ->
            let
                _ =
                    Debug.log "decls" decls
            in
            []
        )


file : Elm.File
file =
    Elm.file [ "HelloWorld" ]
        [ Elm.declaration "hello"
            (Elm.string "World!")
        ]
