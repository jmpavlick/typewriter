module Builder exposing (..)

import Ast exposing (Value(..))
import Dict exposing (Dict)
import Elm
import Elm.Annotation as Type
import List.Ext
import String.Extra



-- toTypeAnnotation_ : () -> Ast.Value -> Type.Annotation
-- toTypeAnnotation_ () =
--     Maybe.withDefault (Type.named [] "Never")
--         << Ast.optMap (toTypeAnnotationOpts ())


toTypeAnnotation : () -> Ast.Value -> Result String Type.Annotation
toTypeAnnotation () =
    Result.fromMaybe "No type mapped for this AST value"
        << Ast.optMap_deprecated (toTypeAnnotationOpts ())


toTypeAnnotationOpts : () -> List (Ast.Attr_Deprecated Type.Annotation)
toTypeAnnotationOpts _ =
    let
        isOptional : Ast.Value -> Bool
        isOptional v =
            Maybe.withDefault False <|
                Ast.optMap_deprecated
                    [ Ast.onNullable_deprecated (always <| Just True)
                    , Ast.onOptional_deprecated (always <| Just True)
                    ]
                    v

        lookaheadOnOptional : Ast.Value -> Maybe Type.Annotation
        lookaheadOnOptional next =
            case toTypeAnnotation () next of
                Err _ ->
                    Nothing

                Ok nextAnnotation ->
                    Just
                        (if isOptional next then
                            nextAnnotation

                         else
                            Type.maybe <| nextAnnotation
                        )
    in
    [ Ast.onString_deprecated Type.string
    , Ast.onInt_deprecated Type.int
    , Ast.onBool_deprecated Type.bool
    , Ast.onFloat_deprecated Type.float
    , Ast.onOptional_deprecated (\next -> lookaheadOnOptional next)
    , Ast.onNullable_deprecated (\next -> lookaheadOnOptional next)
    , Ast.onArray_deprecated (\next -> Result.toMaybe <| Result.map Type.list <| toTypeAnnotation () next)
    , Ast.onObject_deprecated
        (\dict ->
            Just <|
                Type.record <|
                    List.map (Tuple.mapSecond (Result.withDefault (Type.named [] "Never"))) <|
                        Dict.toList <|
                            Dict.map
                                (\_ typedef ->
                                    toTypeAnnotation () typedef
                                )
                                dict
        )
    ]


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
