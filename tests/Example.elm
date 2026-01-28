module Example exposing (suite)

import Ast exposing (Value(..))
import Dict
import Expect
import Json.Decode as D
import Test exposing (..)


suite : Test
suite =
    describe "should decode values"
        [ test "should decode the value OK" <|
            \() ->
                D.decodeString Ast.decoder """{"def": {"type": "string"},"format": null,"maxLength": null,"minLength": null,"type": "string"}"""
                    |> Expect.equal (Ok SString)
        , test "should decode an optional string OK" <|
            \() ->
                D.decodeString Ast.decoder """{"def":{"innerType":{"def":{"type":"string"},"format":null,"maxLength":null,"minLength":null,"type":"string"},"type":"optional"},"type":"optional"}"""
                    |> Expect.equal (Ok (SOptional SString))
        , test "should decode a simple object OK" <|
            \() ->
                D.decodeString Ast.decoder """{"def":{"shape":{"name":{"def":{"type":"string"},"format":null,"maxLength":null,"minLength":null,"type":"string"}},"type":"object"},"type":"object"}"""
                    |> Expect.equal (Ok (SObject (Dict.fromList [ ( "name", SString ) ])))
        , test "should decode an object with an object inside of it OK" <|
            \() ->
                D.decodeString Ast.decoder """{"def":{"shape":{"user":{"def":{"shape":{"age":{"def":{"innerType":{"def":{"abort":false,"check":"number_format","format":"safeint","type":"number"},"format":"safeint","isFinite":true,"isInt":true,"maxValue":9007199254740991,"minValue":-9007199254740991,"type":"number"},"type":"optional"},"type":"optional"},"name":{"def":{"type":"string"},"format":null,"maxLength":null,"minLength":null,"type":"string"}},"type":"object"},"type":"object"}},"type":"object"},"type":"object"}"""
                    |> Expect.equal
                        (Ok
                            (SObject
                                (Dict.fromList
                                    [ ( "user"
                                      , SObject
                                            (Dict.fromList
                                                [ ( "name", SString )
                                                , ( "age", SOptional SInt )
                                                ]
                                            )
                                      )
                                    ]
                                )
                            )
                        )
        , test "should decode this bizarre monstrosity" <|
            \() ->
                D.decodeString Ast.decoder """{"def":{"element":{"def":{"innerType":{"def":{"shape":{"dice":{"def":{"shape":{"sides":{"def":{"element":{"def":{"abort":false,"check":"number_format","format":"safeint","type":"number"},"format":"safeint","isFinite":true,"isInt":true,"maxValue":9007199254740991,"minValue":-9007199254740991,"type":"number"},"type":"array"},"element":{"def":{"abort":false,"check":"number_format","format":"safeint","type":"number"},"format":"safeint","isFinite":true,"isInt":true,"maxValue":9007199254740991,"minValue":-9007199254740991,"type":"number"},"type":"array"},"type":{"def":{"innerType":{"def":{"innerType":{"def":{"type":"string"},"format":null,"maxLength":null,"minLength":null,"type":"string"},"type":"nullable"},"type":"nullable"},"type":"optional"},"type":"optional"},"weight":{"def":{"innerType":{"def":{"checks":[],"type":"number"},"format":null,"isFinite":true,"isInt":false,"maxValue":null,"minValue":null,"type":"number"},"type":"nullable"},"type":"nullable"}},"type":"object"},"type":"object"},"names":{"def":{"element":{"def":{"type":"string"},"format":null,"maxLength":null,"minLength":null,"type":"string"},"type":"array"},"element":{"def":{"type":"string"},"format":null,"maxLength":null,"minLength":null,"type":"string"},"type":"array"}},"type":"object"},"type":"object"},"type":"optional"},"type":"optional"},"type":"array"},"element":{"def":{"innerType":{"def":{"shape":{"dice":{"def":{"shape":{"sides":{"def":{"element":{"def":{"abort":false,"check":"number_format","format":"safeint","type":"number"},"format":"safeint","isFinite":true,"isInt":true,"maxValue":9007199254740991,"minValue":-9007199254740991,"type":"number"},"type":"array"},"element":{"def":{"abort":false,"check":"number_format","format":"safeint","type":"number"},"format":"safeint","isFinite":true,"isInt":true,"maxValue":9007199254740991,"minValue":-9007199254740991,"type":"number"},"type":"array"},"type":{"def":{"innerType":{"def":{"innerType":{"def":{"type":"string"},"format":null,"maxLength":null,"minLength":null,"type":"string"},"type":"nullable"},"type":"nullable"},"type":"optional"},"type":"optional"},"weight":{"def":{"innerType":{"def":{"checks":[],"type":"number"},"format":null,"isFinite":true,"isInt":false,"maxValue":null,"minValue":null,"type":"number"},"type":"nullable"},"type":"nullable"}},"type":"object"},"type":"object"},"names":{"def":{"element":{"def":{"type":"string"},"format":null,"maxLength":null,"minLength":null,"type":"string"},"type":"array"},"element":{"def":{"type":"string"},"format":null,"maxLength":null,"minLength":null,"type":"string"},"type":"array"}},"type":"object"},"type":"object"},"type":"optional"},"type":"optional"},"type":"array"}"""
                    |> Expect.equal
                        (Ok
                            (SArray
                                (SOptional
                                    (SObject
                                        (Dict.fromList
                                            [ ( "dice"
                                              , SObject
                                                    (Dict.fromList
                                                        [ ( "sides", SArray SInt )
                                                        , ( "type", SOptional (SNullable SString) )
                                                        , ( "weight", SNullable SFloat )
                                                        ]
                                                    )
                                              )
                                            , ( "names", SArray SString )
                                            ]
                                        )
                                    )
                                )
                            )
                        )
        ]
