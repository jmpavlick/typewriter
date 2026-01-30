module Builder exposing (..)

import Ast exposing (Value(..))
import Dict exposing (Dict)
import Elm
import Elm.Annotation as Type
import List.Ext
import String.Extra


toTypeAnnotation : () -> Ast.Value -> Result String Type.Annotation
toTypeAnnotation () =
    Ast.cata
        { sString = Ok Type.string
        , sInt = Ok Type.int
        , sFloat = Ok Type.float
        , sBool = Ok Type.bool
        , sOptional = Result.map Type.maybe
        , sNullable = Result.map Type.maybe
        , sArray = Result.map Type.list
        , sObject =
            \dict ->
                dict
                    |> Dict.toList
                    |> List.foldr
                        (\( k, resultAnnotation ) acc ->
                            Result.map2 (\annotation rest -> ( k, annotation ) :: rest) resultAnnotation acc
                        )
                        (Ok [])
                    |> Result.map Type.record
        , sUnimplemented = \str -> Err ("Unimplemented type: " ++ str)
        }


toTypeDecl : Ast.Value -> Result String Elm.Declaration
toTypeDecl typedef =
    Result.map (Elm.alias "Value") <| toTypeAnnotation () typedef


build : List String -> Ast.Decl -> ( ( String, List String ), Maybe Elm.File )
build path ( moduleName, typedef ) =
    let
        ( errs, decls ) =
            List.Ext.partitionMapResult identity <|
                List.Ext.concatAp typedef
                    [ toTypeDecl >> List.singleton
                    ]

        buildFile =
            Elm.file (List.map (String.Extra.toTitleCase << String.Extra.camelize) <| List.concat [ path, [ moduleName ] ])
    in
    ( ( moduleName, errs )
    , if List.length decls == 0 then
        Nothing

      else
        Just <| buildFile decls
    )
