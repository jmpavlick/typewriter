module GenerateZodBindings exposing (main)

{-| -}

import Gen.CodeGen.Generate as Generate
import Generator
import Json.Encode


main : Program Json.Encode.Value () ()
main =
    Generator.toCodegenProgram Generate.fromJson
