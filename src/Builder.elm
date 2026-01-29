module Builder exposing (..)

import Ast exposing (Value(..))
import Dict exposing (Dict)
import Elm
import Elm.Annotation as Type
import List.Ext
import String.Extra


toTypeAnnotation : () -> Ast.Value -> Type.Annotation
toTypeAnnotation () =
    Maybe.withDefault (Type.named [] "Never")
        << Ast.optMap (toTypeAnnotationOpts ())


toTypeAnnotationOpts : () -> List (Ast.Attr Type.Annotation)
toTypeAnnotationOpts _ =
    let
        isOptional : Ast.Value -> Bool
        isOptional v =
            Maybe.withDefault False <|
                Ast.optMap
                    [ Ast.onNullable (always True)
                    , Ast.onOptional (always True)
                    ]
                    v

        lookaheadOnOptional : Ast.Value -> Type.Annotation
        lookaheadOnOptional next =
            if isOptional next then
                toTypeAnnotation () next

            else
                Type.maybe <| toTypeAnnotation () next
    in
    [ Ast.onString Type.string
    , Ast.onInt Type.int
    , Ast.onBool Type.bool
    , Ast.onFloat Type.float
    , Ast.onOptional (\next -> lookaheadOnOptional next)
    , Ast.onNullable (\next -> lookaheadOnOptional next)
    , Ast.onArray (\next -> Type.list <| toTypeAnnotation () next)
    , Ast.onObject
        (\dict ->
            Type.record <|
                Dict.toList <|
                    Dict.map
                        (\_ typedef ->
                            toTypeAnnotation () typedef
                        )
                        dict
        )
    ]


toTypeDecl : Ast.Value -> Elm.Declaration
toTypeDecl typedef =
    Elm.alias "Value" <| toTypeAnnotation () typedef


toFile : List String -> Ast.Decl -> Elm.File
toFile path ( moduleName, typedef ) =
    Elm.file (List.map (String.Extra.toTitleCase << String.Extra.camelize) <| List.concat [ path, [ moduleName ] ]) <|
        List.Ext.concatAp typedef
            [ toTypeDecl >> List.singleton
            ]
