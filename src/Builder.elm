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
        << Ast.optMap (toTypeAnnotationOpts ())


toTypeAnnotationOpts : () -> List (Ast.Attr Type.Annotation)
toTypeAnnotationOpts _ =
    let
        isOptional : Ast.Value -> Bool
        isOptional v =
            Maybe.withDefault False <|
                Ast.optMap
                    [ Ast.onNullable (always <| Just True)
                    , Ast.onOptional (always <| Just True)
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
    [ Ast.onString Type.string
    , Ast.onInt Type.int
    , Ast.onBool Type.bool
    , Ast.onFloat Type.float
    , Ast.onOptional (\next -> lookaheadOnOptional next)
    , Ast.onNullable (\next -> lookaheadOnOptional next)
    , Ast.onArray (\next -> Result.toMaybe <| Result.map Type.list <| toTypeAnnotation () next)
    , Ast.onObject
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
