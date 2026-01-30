module Gen.BigInt exposing
    ( moduleName_, fromInt, fromIntString, fromHexString, toString, toHexString
    , add, sub, mul, div, modBy, divmod, pow
    , gcd, abs, negate, compare, gt, gte, lt
    , lte, max, min, isEven, isOdd, annotation_, call_
    , values_
    )

{-|
# Generated bindings for BigInt

@docs moduleName_, fromInt, fromIntString, fromHexString, toString, toHexString
@docs add, sub, mul, div, modBy, divmod
@docs pow, gcd, abs, negate, compare, gt
@docs gte, lt, lte, max, min, isEven
@docs isOdd, annotation_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "BigInt" ]


{-| Makes a BigInt from an Int

fromInt: Int -> BigInt.BigInt
-}
fromInt : Int -> Elm.Expression
fromInt fromIntArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "fromInt"
             , annotation =
                 Just
                     (Type.function
                          [ Type.int ]
                          (Type.namedWith [ "BigInt" ] "BigInt" [])
                     )
             }
        )
        [ Elm.int fromIntArg_ ]


{-| Makes a BigInt from an integer string, positive or negative

    fromIntString "123" == Just (BigInt.Pos ...)
    fromIntString "-123" == Just (BigInt.Neg ...)
    fromIntString "" == Nothing
    fromIntString "this is not a number :P" == Nothing

fromIntString: String -> Maybe BigInt.BigInt
-}
fromIntString : String -> Elm.Expression
fromIntString fromIntStringArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "fromIntString"
             , annotation =
                 Just
                     (Type.function
                          [ Type.string ]
                          (Type.maybe (Type.namedWith [ "BigInt" ] "BigInt" []))
                     )
             }
        )
        [ Elm.string fromIntStringArg_ ]


{-| Makes a BigInt from a base16 hex string, positive or negative.

    fromHexString "4b6" == Just (BigInt.Pos ...)
    fromHexString "-13d" == Just (BigInt.Neg ...)

    fromHexString "0x456" == Just (BigInt.Pos ...)
    fromHexString "-0x123" == Just (BigInt.Neg ...)

    fromHexString "R2D2" == Nothing
    fromHexString "0xC3P0" == Nothing
    fromHexString "0x" == Nothing
    fromHexString "" == Nothing

**Note:** String can be prepended with or without any combination of "0x", and "+" or "-".

fromHexString: String -> Maybe BigInt.BigInt
-}
fromHexString : String -> Elm.Expression
fromHexString fromHexStringArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "fromHexString"
             , annotation =
                 Just
                     (Type.function
                          [ Type.string ]
                          (Type.maybe (Type.namedWith [ "BigInt" ] "BigInt" []))
                     )
             }
        )
        [ Elm.string fromHexStringArg_ ]


{-| Convert the BigInt to an integer string

toString: BigInt.BigInt -> String
-}
toString : Elm.Expression -> Elm.Expression
toString toStringArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "toString"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                          Type.string
                     )
             }
        )
        [ toStringArg_ ]


{-| Convert the BigInt to a hex string.

    toHexString (BigInt.fromInt 255) == "ff"

**Note:** "0x" will NOT be prepended to the output.

toHexString: BigInt.BigInt -> String
-}
toHexString : Elm.Expression -> Elm.Expression
toHexString toHexStringArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "toHexString"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                          Type.string
                     )
             }
        )
        [ toHexStringArg_ ]


{-| Adds two BigInts

add: BigInt.BigInt -> BigInt.BigInt -> BigInt.BigInt
-}
add : Elm.Expression -> Elm.Expression -> Elm.Expression
add addArg_ addArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "add"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" []
                          , Type.namedWith [ "BigInt" ] "BigInt" []
                          ]
                          (Type.namedWith [ "BigInt" ] "BigInt" [])
                     )
             }
        )
        [ addArg_, addArg_0 ]


{-| Substracts the second BigInt from the first

sub: BigInt.BigInt -> BigInt.BigInt -> BigInt.BigInt
-}
sub : Elm.Expression -> Elm.Expression -> Elm.Expression
sub subArg_ subArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "sub"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" []
                          , Type.namedWith [ "BigInt" ] "BigInt" []
                          ]
                          (Type.namedWith [ "BigInt" ] "BigInt" [])
                     )
             }
        )
        [ subArg_, subArg_0 ]


{-| Multiplies two BigInts

mul: BigInt.BigInt -> BigInt.BigInt -> BigInt.BigInt
-}
mul : Elm.Expression -> Elm.Expression -> Elm.Expression
mul mulArg_ mulArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "mul"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" []
                          , Type.namedWith [ "BigInt" ] "BigInt" []
                          ]
                          (Type.namedWith [ "BigInt" ] "BigInt" [])
                     )
             }
        )
        [ mulArg_, mulArg_0 ]


{-| BigInt division. Produces 0 when dividing by 0 (like (//)).

div: BigInt.BigInt -> BigInt.BigInt -> BigInt.BigInt
-}
div : Elm.Expression -> Elm.Expression -> Elm.Expression
div divArg_ divArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "div"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" []
                          , Type.namedWith [ "BigInt" ] "BigInt" []
                          ]
                          (Type.namedWith [ "BigInt" ] "BigInt" [])
                     )
             }
        )
        [ divArg_, divArg_0 ]


{-| Modulus.

    modBy (BigInt.fromInt 3) (BigInt.fromInt 3)

**Note:** This function returns negative values when
the second argument is negative, unlike Basics.modBy.

modBy: BigInt.BigInt -> BigInt.BigInt -> Maybe BigInt.BigInt
-}
modBy : Elm.Expression -> Elm.Expression -> Elm.Expression
modBy modByArg_ modByArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "modBy"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" []
                          , Type.namedWith [ "BigInt" ] "BigInt" []
                          ]
                          (Type.maybe (Type.namedWith [ "BigInt" ] "BigInt" []))
                     )
             }
        )
        [ modByArg_, modByArg_0 ]


{-| Division and modulus

divmod: BigInt.BigInt -> BigInt.BigInt -> Maybe ( BigInt.BigInt, BigInt.BigInt )
-}
divmod : Elm.Expression -> Elm.Expression -> Elm.Expression
divmod divmodArg_ divmodArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "divmod"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" []
                          , Type.namedWith [ "BigInt" ] "BigInt" []
                          ]
                          (Type.maybe
                               (Type.tuple
                                    (Type.namedWith [ "BigInt" ] "BigInt" [])
                                    (Type.namedWith [ "BigInt" ] "BigInt" [])
                               )
                          )
                     )
             }
        )
        [ divmodArg_, divmodArg_0 ]


{-| Power/Exponentiation.

pow: BigInt.BigInt -> BigInt.BigInt -> BigInt.BigInt
-}
pow : Elm.Expression -> Elm.Expression -> Elm.Expression
pow powArg_ powArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "pow"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" []
                          , Type.namedWith [ "BigInt" ] "BigInt" []
                          ]
                          (Type.namedWith [ "BigInt" ] "BigInt" [])
                     )
             }
        )
        [ powArg_, powArg_0 ]


{-| Compute the Greatest Common Divisors of two numbers.

gcd: BigInt.BigInt -> BigInt.BigInt -> BigInt.BigInt
-}
gcd : Elm.Expression -> Elm.Expression -> Elm.Expression
gcd gcdArg_ gcdArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "gcd"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" []
                          , Type.namedWith [ "BigInt" ] "BigInt" []
                          ]
                          (Type.namedWith [ "BigInt" ] "BigInt" [])
                     )
             }
        )
        [ gcdArg_, gcdArg_0 ]


{-| Absolute value

abs: BigInt.BigInt -> BigInt.BigInt
-}
abs : Elm.Expression -> Elm.Expression
abs absArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "abs"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                          (Type.namedWith [ "BigInt" ] "BigInt" [])
                     )
             }
        )
        [ absArg_ ]


{-| Changes the sign of an BigInt

negate: BigInt.BigInt -> BigInt.BigInt
-}
negate : Elm.Expression -> Elm.Expression
negate negateArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "negate"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                          (Type.namedWith [ "BigInt" ] "BigInt" [])
                     )
             }
        )
        [ negateArg_ ]


{-| Compares two BigInts

compare: BigInt.BigInt -> BigInt.BigInt -> Basics.Order
-}
compare : Elm.Expression -> Elm.Expression -> Elm.Expression
compare compareArg_ compareArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "compare"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" []
                          , Type.namedWith [ "BigInt" ] "BigInt" []
                          ]
                          (Type.namedWith [ "Basics" ] "Order" [])
                     )
             }
        )
        [ compareArg_, compareArg_0 ]


{-| Greater than

gt: BigInt.BigInt -> BigInt.BigInt -> Bool
-}
gt : Elm.Expression -> Elm.Expression -> Elm.Expression
gt gtArg_ gtArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "gt"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" []
                          , Type.namedWith [ "BigInt" ] "BigInt" []
                          ]
                          Type.bool
                     )
             }
        )
        [ gtArg_, gtArg_0 ]


{-| Greater than or equals

gte: BigInt.BigInt -> BigInt.BigInt -> Bool
-}
gte : Elm.Expression -> Elm.Expression -> Elm.Expression
gte gteArg_ gteArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "gte"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" []
                          , Type.namedWith [ "BigInt" ] "BigInt" []
                          ]
                          Type.bool
                     )
             }
        )
        [ gteArg_, gteArg_0 ]


{-| Less than

lt: BigInt.BigInt -> BigInt.BigInt -> Bool
-}
lt : Elm.Expression -> Elm.Expression -> Elm.Expression
lt ltArg_ ltArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "lt"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" []
                          , Type.namedWith [ "BigInt" ] "BigInt" []
                          ]
                          Type.bool
                     )
             }
        )
        [ ltArg_, ltArg_0 ]


{-| Less than or equals

lte: BigInt.BigInt -> BigInt.BigInt -> Bool
-}
lte : Elm.Expression -> Elm.Expression -> Elm.Expression
lte lteArg_ lteArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "lte"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" []
                          , Type.namedWith [ "BigInt" ] "BigInt" []
                          ]
                          Type.bool
                     )
             }
        )
        [ lteArg_, lteArg_0 ]


{-| Returns the largest of two BigInts

max: BigInt.BigInt -> BigInt.BigInt -> BigInt.BigInt
-}
max : Elm.Expression -> Elm.Expression -> Elm.Expression
max maxArg_ maxArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "max"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" []
                          , Type.namedWith [ "BigInt" ] "BigInt" []
                          ]
                          (Type.namedWith [ "BigInt" ] "BigInt" [])
                     )
             }
        )
        [ maxArg_, maxArg_0 ]


{-| Returns the smallest of two BigInts

min: BigInt.BigInt -> BigInt.BigInt -> BigInt.BigInt
-}
min : Elm.Expression -> Elm.Expression -> Elm.Expression
min minArg_ minArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "min"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" []
                          , Type.namedWith [ "BigInt" ] "BigInt" []
                          ]
                          (Type.namedWith [ "BigInt" ] "BigInt" [])
                     )
             }
        )
        [ minArg_, minArg_0 ]


{-| Parity Check - Even.

isEven: BigInt.BigInt -> Bool
-}
isEven : Elm.Expression -> Elm.Expression
isEven isEvenArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "isEven"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                          Type.bool
                     )
             }
        )
        [ isEvenArg_ ]


{-| Parity Check - Odd.

isOdd: BigInt.BigInt -> Bool
-}
isOdd : Elm.Expression -> Elm.Expression
isOdd isOddArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "BigInt" ]
             , name = "isOdd"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                          Type.bool
                     )
             }
        )
        [ isOddArg_ ]


annotation_ : { bigInt : Type.Annotation }
annotation_ =
    { bigInt = Type.namedWith [ "BigInt" ] "BigInt" [] }


call_ :
    { fromInt : Elm.Expression -> Elm.Expression
    , fromIntString : Elm.Expression -> Elm.Expression
    , fromHexString : Elm.Expression -> Elm.Expression
    , toString : Elm.Expression -> Elm.Expression
    , toHexString : Elm.Expression -> Elm.Expression
    , add : Elm.Expression -> Elm.Expression -> Elm.Expression
    , sub : Elm.Expression -> Elm.Expression -> Elm.Expression
    , mul : Elm.Expression -> Elm.Expression -> Elm.Expression
    , div : Elm.Expression -> Elm.Expression -> Elm.Expression
    , modBy : Elm.Expression -> Elm.Expression -> Elm.Expression
    , divmod : Elm.Expression -> Elm.Expression -> Elm.Expression
    , pow : Elm.Expression -> Elm.Expression -> Elm.Expression
    , gcd : Elm.Expression -> Elm.Expression -> Elm.Expression
    , abs : Elm.Expression -> Elm.Expression
    , negate : Elm.Expression -> Elm.Expression
    , compare : Elm.Expression -> Elm.Expression -> Elm.Expression
    , gt : Elm.Expression -> Elm.Expression -> Elm.Expression
    , gte : Elm.Expression -> Elm.Expression -> Elm.Expression
    , lt : Elm.Expression -> Elm.Expression -> Elm.Expression
    , lte : Elm.Expression -> Elm.Expression -> Elm.Expression
    , max : Elm.Expression -> Elm.Expression -> Elm.Expression
    , min : Elm.Expression -> Elm.Expression -> Elm.Expression
    , isEven : Elm.Expression -> Elm.Expression
    , isOdd : Elm.Expression -> Elm.Expression
    }
call_ =
    { fromInt =
        \fromIntArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "fromInt"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.int ]
                                  (Type.namedWith [ "BigInt" ] "BigInt" [])
                             )
                     }
                )
                [ fromIntArg_ ]
    , fromIntString =
        \fromIntStringArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "fromIntString"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.string ]
                                  (Type.maybe
                                       (Type.namedWith [ "BigInt" ] "BigInt" [])
                                  )
                             )
                     }
                )
                [ fromIntStringArg_ ]
    , fromHexString =
        \fromHexStringArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "fromHexString"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.string ]
                                  (Type.maybe
                                       (Type.namedWith [ "BigInt" ] "BigInt" [])
                                  )
                             )
                     }
                )
                [ fromHexStringArg_ ]
    , toString =
        \toStringArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "toString"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                                  Type.string
                             )
                     }
                )
                [ toStringArg_ ]
    , toHexString =
        \toHexStringArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "toHexString"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                                  Type.string
                             )
                     }
                )
                [ toHexStringArg_ ]
    , add =
        \addArg_ addArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "add"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" []
                                  , Type.namedWith [ "BigInt" ] "BigInt" []
                                  ]
                                  (Type.namedWith [ "BigInt" ] "BigInt" [])
                             )
                     }
                )
                [ addArg_, addArg_0 ]
    , sub =
        \subArg_ subArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "sub"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" []
                                  , Type.namedWith [ "BigInt" ] "BigInt" []
                                  ]
                                  (Type.namedWith [ "BigInt" ] "BigInt" [])
                             )
                     }
                )
                [ subArg_, subArg_0 ]
    , mul =
        \mulArg_ mulArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "mul"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" []
                                  , Type.namedWith [ "BigInt" ] "BigInt" []
                                  ]
                                  (Type.namedWith [ "BigInt" ] "BigInt" [])
                             )
                     }
                )
                [ mulArg_, mulArg_0 ]
    , div =
        \divArg_ divArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "div"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" []
                                  , Type.namedWith [ "BigInt" ] "BigInt" []
                                  ]
                                  (Type.namedWith [ "BigInt" ] "BigInt" [])
                             )
                     }
                )
                [ divArg_, divArg_0 ]
    , modBy =
        \modByArg_ modByArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "modBy"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" []
                                  , Type.namedWith [ "BigInt" ] "BigInt" []
                                  ]
                                  (Type.maybe
                                       (Type.namedWith [ "BigInt" ] "BigInt" [])
                                  )
                             )
                     }
                )
                [ modByArg_, modByArg_0 ]
    , divmod =
        \divmodArg_ divmodArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "divmod"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" []
                                  , Type.namedWith [ "BigInt" ] "BigInt" []
                                  ]
                                  (Type.maybe
                                       (Type.tuple
                                            (Type.namedWith
                                                 [ "BigInt" ]
                                                 "BigInt"
                                                 []
                                            )
                                            (Type.namedWith
                                                 [ "BigInt" ]
                                                 "BigInt"
                                                 []
                                            )
                                       )
                                  )
                             )
                     }
                )
                [ divmodArg_, divmodArg_0 ]
    , pow =
        \powArg_ powArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "pow"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" []
                                  , Type.namedWith [ "BigInt" ] "BigInt" []
                                  ]
                                  (Type.namedWith [ "BigInt" ] "BigInt" [])
                             )
                     }
                )
                [ powArg_, powArg_0 ]
    , gcd =
        \gcdArg_ gcdArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "gcd"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" []
                                  , Type.namedWith [ "BigInt" ] "BigInt" []
                                  ]
                                  (Type.namedWith [ "BigInt" ] "BigInt" [])
                             )
                     }
                )
                [ gcdArg_, gcdArg_0 ]
    , abs =
        \absArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "abs"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                                  (Type.namedWith [ "BigInt" ] "BigInt" [])
                             )
                     }
                )
                [ absArg_ ]
    , negate =
        \negateArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "negate"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                                  (Type.namedWith [ "BigInt" ] "BigInt" [])
                             )
                     }
                )
                [ negateArg_ ]
    , compare =
        \compareArg_ compareArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "compare"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" []
                                  , Type.namedWith [ "BigInt" ] "BigInt" []
                                  ]
                                  (Type.namedWith [ "Basics" ] "Order" [])
                             )
                     }
                )
                [ compareArg_, compareArg_0 ]
    , gt =
        \gtArg_ gtArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "gt"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" []
                                  , Type.namedWith [ "BigInt" ] "BigInt" []
                                  ]
                                  Type.bool
                             )
                     }
                )
                [ gtArg_, gtArg_0 ]
    , gte =
        \gteArg_ gteArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "gte"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" []
                                  , Type.namedWith [ "BigInt" ] "BigInt" []
                                  ]
                                  Type.bool
                             )
                     }
                )
                [ gteArg_, gteArg_0 ]
    , lt =
        \ltArg_ ltArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "lt"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" []
                                  , Type.namedWith [ "BigInt" ] "BigInt" []
                                  ]
                                  Type.bool
                             )
                     }
                )
                [ ltArg_, ltArg_0 ]
    , lte =
        \lteArg_ lteArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "lte"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" []
                                  , Type.namedWith [ "BigInt" ] "BigInt" []
                                  ]
                                  Type.bool
                             )
                     }
                )
                [ lteArg_, lteArg_0 ]
    , max =
        \maxArg_ maxArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "max"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" []
                                  , Type.namedWith [ "BigInt" ] "BigInt" []
                                  ]
                                  (Type.namedWith [ "BigInt" ] "BigInt" [])
                             )
                     }
                )
                [ maxArg_, maxArg_0 ]
    , min =
        \minArg_ minArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "min"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" []
                                  , Type.namedWith [ "BigInt" ] "BigInt" []
                                  ]
                                  (Type.namedWith [ "BigInt" ] "BigInt" [])
                             )
                     }
                )
                [ minArg_, minArg_0 ]
    , isEven =
        \isEvenArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "isEven"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                                  Type.bool
                             )
                     }
                )
                [ isEvenArg_ ]
    , isOdd =
        \isOddArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "BigInt" ]
                     , name = "isOdd"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                                  Type.bool
                             )
                     }
                )
                [ isOddArg_ ]
    }


values_ :
    { fromInt : Elm.Expression
    , fromIntString : Elm.Expression
    , fromHexString : Elm.Expression
    , toString : Elm.Expression
    , toHexString : Elm.Expression
    , add : Elm.Expression
    , sub : Elm.Expression
    , mul : Elm.Expression
    , div : Elm.Expression
    , modBy : Elm.Expression
    , divmod : Elm.Expression
    , pow : Elm.Expression
    , gcd : Elm.Expression
    , abs : Elm.Expression
    , negate : Elm.Expression
    , compare : Elm.Expression
    , gt : Elm.Expression
    , gte : Elm.Expression
    , lt : Elm.Expression
    , lte : Elm.Expression
    , max : Elm.Expression
    , min : Elm.Expression
    , isEven : Elm.Expression
    , isOdd : Elm.Expression
    }
values_ =
    { fromInt =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "fromInt"
            , annotation =
                Just
                    (Type.function
                         [ Type.int ]
                         (Type.namedWith [ "BigInt" ] "BigInt" [])
                    )
            }
    , fromIntString =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "fromIntString"
            , annotation =
                Just
                    (Type.function
                         [ Type.string ]
                         (Type.maybe (Type.namedWith [ "BigInt" ] "BigInt" []))
                    )
            }
    , fromHexString =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "fromHexString"
            , annotation =
                Just
                    (Type.function
                         [ Type.string ]
                         (Type.maybe (Type.namedWith [ "BigInt" ] "BigInt" []))
                    )
            }
    , toString =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                         Type.string
                    )
            }
    , toHexString =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "toHexString"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                         Type.string
                    )
            }
    , add =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "add"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" []
                         , Type.namedWith [ "BigInt" ] "BigInt" []
                         ]
                         (Type.namedWith [ "BigInt" ] "BigInt" [])
                    )
            }
    , sub =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "sub"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" []
                         , Type.namedWith [ "BigInt" ] "BigInt" []
                         ]
                         (Type.namedWith [ "BigInt" ] "BigInt" [])
                    )
            }
    , mul =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "mul"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" []
                         , Type.namedWith [ "BigInt" ] "BigInt" []
                         ]
                         (Type.namedWith [ "BigInt" ] "BigInt" [])
                    )
            }
    , div =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "div"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" []
                         , Type.namedWith [ "BigInt" ] "BigInt" []
                         ]
                         (Type.namedWith [ "BigInt" ] "BigInt" [])
                    )
            }
    , modBy =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "modBy"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" []
                         , Type.namedWith [ "BigInt" ] "BigInt" []
                         ]
                         (Type.maybe (Type.namedWith [ "BigInt" ] "BigInt" []))
                    )
            }
    , divmod =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "divmod"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" []
                         , Type.namedWith [ "BigInt" ] "BigInt" []
                         ]
                         (Type.maybe
                              (Type.tuple
                                   (Type.namedWith [ "BigInt" ] "BigInt" [])
                                   (Type.namedWith [ "BigInt" ] "BigInt" [])
                              )
                         )
                    )
            }
    , pow =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "pow"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" []
                         , Type.namedWith [ "BigInt" ] "BigInt" []
                         ]
                         (Type.namedWith [ "BigInt" ] "BigInt" [])
                    )
            }
    , gcd =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "gcd"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" []
                         , Type.namedWith [ "BigInt" ] "BigInt" []
                         ]
                         (Type.namedWith [ "BigInt" ] "BigInt" [])
                    )
            }
    , abs =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "abs"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                         (Type.namedWith [ "BigInt" ] "BigInt" [])
                    )
            }
    , negate =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "negate"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                         (Type.namedWith [ "BigInt" ] "BigInt" [])
                    )
            }
    , compare =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "compare"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" []
                         , Type.namedWith [ "BigInt" ] "BigInt" []
                         ]
                         (Type.namedWith [ "Basics" ] "Order" [])
                    )
            }
    , gt =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "gt"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" []
                         , Type.namedWith [ "BigInt" ] "BigInt" []
                         ]
                         Type.bool
                    )
            }
    , gte =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "gte"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" []
                         , Type.namedWith [ "BigInt" ] "BigInt" []
                         ]
                         Type.bool
                    )
            }
    , lt =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "lt"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" []
                         , Type.namedWith [ "BigInt" ] "BigInt" []
                         ]
                         Type.bool
                    )
            }
    , lte =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "lte"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" []
                         , Type.namedWith [ "BigInt" ] "BigInt" []
                         ]
                         Type.bool
                    )
            }
    , max =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "max"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" []
                         , Type.namedWith [ "BigInt" ] "BigInt" []
                         ]
                         (Type.namedWith [ "BigInt" ] "BigInt" [])
                    )
            }
    , min =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "min"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" []
                         , Type.namedWith [ "BigInt" ] "BigInt" []
                         ]
                         (Type.namedWith [ "BigInt" ] "BigInt" [])
                    )
            }
    , isEven =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "isEven"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                         Type.bool
                    )
            }
    , isOdd =
        Elm.value
            { importFrom = [ "BigInt" ]
            , name = "isOdd"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "BigInt" ] "BigInt" [] ]
                         Type.bool
                    )
            }
    }