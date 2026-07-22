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
        , describe "singularize"
            [ test "drops a plural s" <|
                \() ->
                    String.Ext.singularize "UnitGroups"
                        |> Expect.equal "UnitGroup"
            , test "rewrites -ies to -y" <|
                \() ->
                    String.Ext.singularize "Entries"
                        |> Expect.equal "Entry"
            , test "leaves -ss and -us words alone" <|
                \() ->
                    ( String.Ext.singularize "Address", String.Ext.singularize "Status" )
                        |> Expect.equal ( "Address", "Status" )
            , test "leaves a singular word alone" <|
                \() ->
                    String.Ext.singularize "Facility"
                        |> Expect.equal "Facility"
            ]
        ]
