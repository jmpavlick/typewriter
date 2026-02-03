module Generator exposing (Args, argsDecoder, toCodegenProgram)

{-| -}

import Ast exposing (Value(..))
import Builder
import Dict
import Elm
import Elm.Declare
import Json.Decode as D
import Maybe.Extra


type alias Args =
    { outputModuleNamespace : List String
    , decls : List Ast.Decl
    }


argsDecoder : D.Decoder Args
argsDecoder =
    D.map2 Args
        (D.field "outputModuleNamespace" <| D.list D.string)
        (D.map Dict.toList <| D.field "decls" <| D.dict Ast.decoder)


type alias GenerateFile =
    { path : String
    , contents : String
    , warnings :
        List
            { declaration : String
            , warning : String
            }
    }


toCodegenProgram : (D.Decoder Args -> (Args -> List GenerateFile) -> c) -> c
toCodegenProgram generateFromJson =
    generateFromJson argsDecoder
        (\{ outputModuleNamespace, decls } ->
            let
                outputs =
                    List.map (Builder.build outputModuleNamespace) decls

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
                        let
                            errsLen =
                                List.length errs
                        in
                        if errsLen > 0 then
                            let
                                _ =
                                    Debug.log "Codegen errors" errsLen
                            in
                            Just f

                        else
                            Nothing
                    )
                    <|
                        Elm.file
                            (outputModuleNamespace ++ [ "AaaaaaaaaErrors" ])
                        <|
                            List.map
                                (\( typeName, messages ) ->
                                    Elm.withDocumentation (typeName ++ ":\n\n" ++ (String.join "\n" <| List.map (\s -> "    - " ++ s) messages)) <|
                                        Elm.declaration typeName Elm.Declare.placeholder
                                )
                                errs
            in
            files ++ Maybe.Extra.toList errModule
        )
