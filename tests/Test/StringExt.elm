module Test.StringExt exposing (suite)

import Expect
import String.Ext
import Test exposing (..)


suite : Test
suite =
    describe "String.Ext.toTypename"
        [ test "strips an apostrophe so the constructor name is a legal Elm identifier" <|
            \() ->
                String.Ext.toTypename "New Year's Day"
                    |> Expect.equal "NewYearsDay"
        , test "leaves an already-valid value unchanged" <|
            \() ->
                String.Ext.toTypename "Closet"
                    |> Expect.equal "Closet"
        , test "camelizes separated words and upper-cases the head" <|
            \() ->
                String.Ext.toTypename "read-write"
                    |> Expect.equal "ReadWrite"
        ]
