module Test.Roundtrip exposing (suite)

{-| the law: for every generated module, `D.decodeValue decoder (encoder v) == Ok v`.

covers each AST node kind through representative generated modules: primitives,
optional/nullable flattening, arrays, tuples (pair / triple / right-nested 4+),
sets, records, nested objects, unit-variant unions (string / int / bool wire),
hoisted nested unions, and discriminated unions.

-}

import BigInt
import Date
import Dict
import Expect
import Hour
import IntegrationTests.BigInt
import IntegrationTests.BoolLiteral
import IntegrationTests.Datetime
import IntegrationTests.EnumRecordInObject
import IntegrationTests.EnumRecordRequiredValues
import IntegrationTests.EnumRecordToplevel
import IntegrationTests.HttpStatus
import IntegrationTests.ImportingPage
import IntegrationTests.InferredKindUnion
import IntegrationTests.IntSet
import IntegrationTests.IsoDate
import IntegrationTests.IsoTime
import IntegrationTests.Nan
import IntegrationTests.Notification
import IntegrationTests.Null
import IntegrationTests.NullableNumber
import IntegrationTests.OptString
import IntegrationTests.PairTuple
import IntegrationTests.PartialEnumRecordInObject
import IntegrationTests.QuintTuple
import IntegrationTests.RecordInObject
import IntegrationTests.SetInObject
import IntegrationTests.SharedChannel
import IntegrationTests.SharedLocale
import IntegrationTests.SimpleUser
import IntegrationTests.StringMap
import IntegrationTests.StringNativeEnum
import IntegrationTests.StringSet
import IntegrationTests.SystemUser
import IntegrationTests.TripleTuple
import IntegrationTests.TupleInObject
import IntegrationTests.UnderscoreFields
import IntegrationTests.Unknown
import IntegrationTests.Url
import IntegrationTests.User
import IntegrationTests.WrappersInObject
import Javascript
import Json.Decode as D
import Json.Encode as E
import Set
import Test exposing (Test, describe, test)
import Time
import Url


{-| `decodeValue decoder << encoder` must be `Ok`
-}
law : String -> (a -> E.Value) -> D.Decoder a -> a -> Test
law name encoder decoder value =
    test name <|
        \_ ->
            Expect.equal (Ok value) (D.decodeValue decoder (encoder value))


exampleUrl : Url.Url
exampleUrl =
    { protocol = Url.Https
    , host = "example.com"
    , port_ = Just 8443
    , path = "/things/1"
    , query = Just "expand=all"
    , fragment = Just "top"
    }


suite : Test
suite =
    describe "decodeValue decoder (encoder v) == Ok v"
        [ describe "primitives and leaves"
            [ law "opt string, present" IntegrationTests.OptString.encoder IntegrationTests.OptString.decoder (Just "hello")
            , law "opt string, absent" IntegrationTests.OptString.encoder IntegrationTests.OptString.decoder Nothing
            , law "nullable number, present" IntegrationTests.NullableNumber.encoder IntegrationTests.NullableNumber.decoder (Just 1.5)
            , law "nullable number, absent" IntegrationTests.NullableNumber.encoder IntegrationTests.NullableNumber.decoder Nothing
            , law "bigint" IntegrationTests.BigInt.encoder IntegrationTests.BigInt.decoder (BigInt.fromInt 9007199254740991)
            , law "url" IntegrationTests.Url.encoder IntegrationTests.Url.decoder exampleUrl
            , law "iso date" IntegrationTests.IsoDate.encoder IntegrationTests.IsoDate.decoder (Date.fromCalendarDate 2026 Time.Aug 7)
            , law "iso time" IntegrationTests.IsoTime.encoder IntegrationTests.IsoTime.decoder (Hour.fromMillis 45296000)
            , law "datetime" IntegrationTests.Datetime.encoder IntegrationTests.Datetime.decoder (Time.millisToPosix 1700000000000)
            , law "nan" IntegrationTests.Nan.encoder IntegrationTests.Nan.decoder Javascript.NaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNaNa
            , law "null" IntegrationTests.Null.encoder IntegrationTests.Null.decoder Javascript.Null
            , law "unknown passes through" IntegrationTests.Unknown.encoder IntegrationTests.Unknown.decoder (E.object [ ( "anything", E.string "goes" ) ])
            ]
        , describe "collections"
            [ law "string set" IntegrationTests.StringSet.encoder IntegrationTests.StringSet.decoder (Set.fromList [ "a", "b", "c" ])
            , law "int set" IntegrationTests.IntSet.encoder IntegrationTests.IntSet.decoder (Set.fromList [ 3, 1, 2 ])
            , law "string map" IntegrationTests.StringMap.encoder IntegrationTests.StringMap.decoder (Dict.fromList [ ( "one", 1 ), ( "two", 2 ) ])
            ]
        , describe "tuples"
            [ law "pair" IntegrationTests.PairTuple.encoder IntegrationTests.PairTuple.decoder ( "x", 1 )
            , law "triple" IntegrationTests.TripleTuple.encoder IntegrationTests.TripleTuple.decoder ( "x", 1, True )
            , law "quint (right-nested pairs)" IntegrationTests.QuintTuple.encoder IntegrationTests.QuintTuple.decoder ( "a", ( 1, ( True, ( 2.5, "z" ) ) ) )
            , law "tuples in object"
                IntegrationTests.TupleInObject.encoder
                IntegrationTests.TupleInObject.decoder
                { coord = ( 1.5, -2.5 ), labeled = ( "label", [ 1, 2, 3 ] ) }
            ]
        , describe "objects"
            [ law "flat object" IntegrationTests.WrappersInObject.encoder IntegrationTests.WrappersInObject.decoder { name = "n", retries = 3 }
            , law "set in object" IntegrationTests.SetInObject.encoder IntegrationTests.SetInObject.decoder { tags = Set.fromList [ "t1", "t2" ] }
            , law "record in object"
                IntegrationTests.RecordInObject.encoder
                IntegrationTests.RecordInObject.decoder
                { sections = Dict.fromList [ ( "intro", { recordThing = "r", some = 1 } ) ] }
            , law "nested object with optionals"
                IntegrationTests.SimpleUser.encoder
                IntegrationTests.SimpleUser.decoder
                { emailAddresses = [ "a@b.c" ]
                , id = "id-1"
                , phoneNumber = Nothing
                , prefs = { lightMode = True, theme = "dark" }
                , username = "user"
                }
            ]
        , describe "unit-variant unions"
            [ law "string enum" IntegrationTests.StringNativeEnum.encoder IntegrationTests.StringNativeEnum.decoder IntegrationTests.StringNativeEnum.A
            , law "int literal union" IntegrationTests.HttpStatus.encoder IntegrationTests.HttpStatus.decoder IntegrationTests.HttpStatus.Int_404
            , law "bool literal" IntegrationTests.BoolLiteral.encoder IntegrationTests.BoolLiteral.decoder IntegrationTests.BoolLiteral.LiteralTrue
            ]
        , describe "hoisted nested unions"
            [ law "user with nested enums and optionals"
                IntegrationTests.User.encoder
                IntegrationTests.User.decoder
                { id = "u1"
                , identities =
                    [ { avatarUrl = Just "https://example.com/a.png"
                      , email = "a@b.c"
                      , firstName = Just "Ada"
                      , identityProvider = IntegrationTests.User.IdentityProviderGithub
                      , lastName = Nothing
                      , nickName = Nothing
                      , tel = Just "555"
                      }
                    ]
                , lastLoggedInAt = Just (Time.millisToPosix 1700000000000)
                , permissions =
                    Just
                        { canEditOwnPosts = Just True
                        , canEditPostsForMembersOfGroups =
                            Just
                                [ IntegrationTests.User.CanEditPostsForMembersOfGroupsModerator
                                , IntegrationTests.User.CanEditPostsForMembersOfGroupsUser
                                ]
                        , canReadPosts = Nothing
                        , canWritePosts = Just False
                        , group = IntegrationTests.User.GroupAdmin
                        }
                , signedUpAt = Time.millisToPosix 1600000000000
                }
            ]
        , describe "imported types"
            [ law "nested types referenced from another config's modules"
                IntegrationTests.ImportingPage.encoder
                IntegrationTests.ImportingPage.decoder
                { alternates = [ { locale = IntegrationTests.SharedLocale.FrCA, urlSlug = "fr" } ]
                , channel = IntegrationTests.SharedChannel.Sms { phone = "555" }
                , locale = IntegrationTests.SharedLocale.EnUS
                , other = IntegrationTests.ImportingPage.OtherY
                , slots =
                    { closet = { label = "closet", priority = 1 }
                    , parking = { label = "parking", priority = 2 }
                    }
                }
            ]
        , describe "vendored extensions"
            [ law "enum record, toplevel, mixed presence"
                IntegrationTests.EnumRecordToplevel.encoder
                IntegrationTests.EnumRecordToplevel.decoder
                { left = Just { n = 1 }, right = Nothing }
            , law "enum record, required values"
                IntegrationTests.EnumRecordRequiredValues.encoder
                IntegrationTests.EnumRecordRequiredValues.decoder
                { sizes = { first = { n = 1 }, second = { n = 2 } } }
            , law "enum record in object"
                IntegrationTests.EnumRecordInObject.encoder
                IntegrationTests.EnumRecordInObject.decoder
                { unitGroups =
                    { closet = Just { label = "Closet", priority = 1 }
                    , small = Nothing
                    , parking = Just { label = "Parking", priority = 3 }
                    }
                }
            , law "partial enum record with sanitized key"
                IntegrationTests.PartialEnumRecordInObject.encoder
                IntegrationTests.PartialEnumRecordInObject.decoder
                { headings = { main_ = Just { text = "hi" }, footer = Nothing } }
            , law "underscore wire field"
                IntegrationTests.UnderscoreFields.encoder
                IntegrationTests.UnderscoreFields.decoder
                { id = "abc", linkText = Nothing }
            , law "inferred-kind union"
                IntegrationTests.InferredKindUnion.encoder
                IntegrationTests.InferredKindUnion.decoder
                { shape = Just (IntegrationTests.InferredKindUnion.ShapeCircle { radius = 2.5 }) }
            ]
        , describe "discriminated unions"
            [ law "notification, email payload"
                IntegrationTests.Notification.encoder
                IntegrationTests.Notification.decoder
                { id = "n1", payload = IntegrationTests.Notification.PayloadEmail { to = "a@b.c" } }
            , law "notification, sms payload"
                IntegrationTests.Notification.encoder
                IntegrationTests.Notification.decoder
                { id = "n2", payload = IntegrationTests.Notification.PayloadSms { phone = "555" } }
            , law "root discriminated union, privileged variant"
                IntegrationTests.SystemUser.encoder
                IntegrationTests.SystemUser.decoder
                (IntegrationTests.SystemUser.PrivilegedUser
                    { user =
                        { role = IntegrationTests.SystemUser.RoleAdmin
                        , user =
                            { emailAddresses = [ "a@b.c" ]
                            , id = "id"
                            , phoneNumber = Just "555"
                            , prefs = { lightMode = False, theme = "light" }
                            , username = "root"
                            }
                        }
                    }
                )
            , law "root discriminated union, plain variant"
                IntegrationTests.SystemUser.encoder
                IntegrationTests.SystemUser.decoder
                (IntegrationTests.SystemUser.User
                    { user =
                        { emailAddresses = []
                        , id = "id2"
                        , phoneNumber = Nothing
                        , prefs = { lightMode = True, theme = "dark" }
                        , username = "pleb"
                        }
                    }
                )
            ]
        ]
