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
import Maybe.Extra


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
            let
                outputs =
                    List.map (Builder.build outputModulePath) decls

                files =
                    Maybe.Extra.values <|
                        List.map Tuple.second outputs

                errs =
                    List.map Tuple.first outputs

                _ =
                    (if List.length errs > 0 then
                        Debug.log "errors"

                     else
                        identity
                    )
                        errs
            in
            files
        )
