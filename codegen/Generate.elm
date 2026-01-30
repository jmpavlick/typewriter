module Generate exposing (main)

{-| -}

import Ast exposing (Value(..))
import Builder
import Dict exposing (Dict)
import Elm
import Elm.Annotation as Type
import Elm.Declare
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
                    List.filterMap
                        (\( ( _, msgs ) as x, _ ) ->
                            if List.length msgs > 0 then
                                Just x

                            else
                                Nothing
                        )
                        outputs

                errModule =
                    (\f ->
                        if List.length errs > 0 then
                            Just f

                        else
                            Nothing
                    )
                    <|
                        Elm.file
                            (outputModulePath ++ [ "AaaaaaaaaErrors" ])
                        <|
                            List.map
                                (\( typeName, messages ) ->
                                    Elm.withDocumentation (String.join "\n\n" <| List.map (\s -> "- " ++ s) messages) <|
                                        Elm.declaration typeName Elm.Declare.placeholder
                                )
                                errs

                _ =
                    (if List.length errs > 0 then
                        Debug.log "errors"

                     else
                        identity
                    )
                        errs
            in
            files ++ Maybe.Extra.toList errModule
        )
