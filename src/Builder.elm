module Builder exposing (..)

import Ast exposing (Value(..))
import Elm
import Elm.Annotation as Type
import List.Ext
import String.Extra


toTypeAnnotation : () -> Ast.Value -> Type.Annotation
toTypeAnnotation () =
    Maybe.withDefault (Type.named [] "Never")
        << Ast.optMap toTypeAnnotationOpts


toTypeAnnotationOpts : List (Ast.Attr Type.Annotation)
toTypeAnnotationOpts =
    []


toTypeDecl : Ast.Value -> Elm.Declaration
toTypeDecl typedef =
    Elm.alias "Value" <| toTypeAnnotation () typedef


toFile : List String -> Ast.Decl -> Elm.File
toFile path ( moduleName, typedef ) =
    Elm.file (List.map (String.Extra.toTitleCase << String.Extra.camelize) <| List.concat [ path, [ moduleName ] ]) <|
        List.Ext.concatAp typedef
            [ toTypeDecl >> List.singleton
            ]
