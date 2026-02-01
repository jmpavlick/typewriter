module Gen.Hour exposing
    ( moduleName_, now, time, fromParts, fromPosix, fromIsoString
    , fromMillis, fromSeconds, hours, minutes, seconds, millis, parts
    , toIsoString, toMillis, toSeconds, format, formatWithLanguage, add, diff
    , ceiling, floor, range, compare, isBetween, min, max
    , clamp, decoder, encode, annotation_, make_, caseOf_, call_
    , values_
    )

{-|
# Generated bindings for Hour

@docs moduleName_, now, time, fromParts, fromPosix, fromIsoString
@docs fromMillis, fromSeconds, hours, minutes, seconds, millis
@docs parts, toIsoString, toMillis, toSeconds, format, formatWithLanguage
@docs add, diff, ceiling, floor, range, compare
@docs isBetween, min, max, clamp, decoder, encode
@docs annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Arg
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Hour" ]


{-| Gets the current time in the local timezone.

now: Task.Task x Hour.Time
-}
now : Elm.Expression
now =
    Elm.value
        { importFrom = [ "Hour" ]
        , name = "now"
        , annotation =
            Just
                (Type.namedWith
                     [ "Task" ]
                     "Task"
                     [ Type.var "x", Type.namedWith [ "Hour" ] "Time" [] ]
                )
        }


{-| Creates a new Time instance from a tuple of hours, minutes, and seconds.

Values are normalized to the range of 0-23 for hours, 0-59 for minutes, and
0-59 for seconds.

    time (13, 5, 0)
        |> toIsoString
    --> "13:05"

Out or range values are normalized:

    time (12, 60, 60)
        |> toIsoString
    --> "13:01"

time: ( Int, Int, Int ) -> Hour.Time
-}
time : Elm.Expression -> Elm.Expression
time timeArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "time"
             , annotation =
                 Just
                     (Type.function
                          [ Type.triple Type.int Type.int Type.int ]
                          (Type.namedWith [ "Hour" ] "Time" [])
                     )
             }
        )
        [ timeArg_ ]


{-| Creates a new Time instance with milliseconds.

    fromParts { hours = 13, minutes = 5, seconds = 0 , millis = 1}
        |> toIsoString
    --> "13:05:00.001"

All values are normalized, so you can pass numbers in invalid ranges and they will
wrap up or down to correct values.

    fromParts {hours = -2, minutes = 100, seconds = 61, millis = 1500}
        |> parts
        --> {hours = 23, minutes = 41, seconds = 2, millis = 500}

fromParts: { hours : Int, minutes : Int, seconds : Int, millis : Int } -> Hour.Time
-}
fromParts :
    { hours : Int, minutes : Int, seconds : Int, millis : Int }
    -> Elm.Expression
fromParts fromPartsArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "fromParts"
             , annotation =
                 Just
                     (Type.function
                          [ Type.record
                              [ ( "hours", Type.int )
                              , ( "minutes", Type.int )
                              , ( "seconds", Type.int )
                              , ( "millis", Type.int )
                              ]
                          ]
                          (Type.namedWith [ "Hour" ] "Time" [])
                     )
             }
        )
        [ Elm.record
            [ Tuple.pair "hours" (Elm.int fromPartsArg_.hours)
            , Tuple.pair "minutes" (Elm.int fromPartsArg_.minutes)
            , Tuple.pair "seconds" (Elm.int fromPartsArg_.seconds)
            , Tuple.pair "millis" (Elm.int fromPartsArg_.millis)
            ]
        ]


{-| Create a Time instance from a Posix timestamp.

    import Time

    fromPosix Time.utc (Time.millisToPosix (12 * 60 * 60 * 1000))
        |> toIsoString
    --> "12:00"

fromPosix: Time.Zone -> Time.Posix -> Hour.Time
-}
fromPosix : Elm.Expression -> Elm.Expression -> Elm.Expression
fromPosix fromPosixArg_ fromPosixArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "fromPosix"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Time" ] "Zone" []
                          , Type.namedWith [ "Time" ] "Posix" []
                          ]
                          (Type.namedWith [ "Hour" ] "Time" [])
                     )
             }
        )
        [ fromPosixArg_, fromPosixArg_0 ]


{-| Parse iso8601 time string to Time.

Expect hours in the format "HH:MM:SS" or "HH:MM:SS.mmm".

    fromIsoString "12:30:05.500"
        |> Maybe.map parts
    --> Just { hours = 12, minutes = 30, seconds = 5, millis = 500 }

fromIsoString: String -> Maybe Hour.Time
-}
fromIsoString : String -> Elm.Expression
fromIsoString fromIsoStringArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "fromIsoString"
             , annotation =
                 Just
                     (Type.function
                          [ Type.string ]
                          (Type.maybe (Type.namedWith [ "Hour" ] "Time" []))
                     )
             }
        )
        [ Elm.string fromIsoStringArg_ ]


{-| Create a Time instance from duration from the start of the day in milliseconds.

    fromMillis (12 * 60 * 60 * 1000)
        |> toIsoString
    --> "12:00"

fromMillis: Int -> Hour.Time
-}
fromMillis : Int -> Elm.Expression
fromMillis fromMillisArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "fromMillis"
             , annotation =
                 Just
                     (Type.function
                          [ Type.int ]
                          (Type.namedWith [ "Hour" ] "Time" [])
                     )
             }
        )
        [ Elm.int fromMillisArg_ ]


{-| Create a Time instance from duration from the start of the day in seconds.

    fromSeconds (12 * 60 * 60)
        |> toIsoString
    --> "12:00"

fromSeconds: Int -> Hour.Time
-}
fromSeconds : Int -> Elm.Expression
fromSeconds fromSecondsArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "fromSeconds"
             , annotation =
                 Just
                     (Type.function
                          [ Type.int ]
                          (Type.namedWith [ "Hour" ] "Time" [])
                     )
             }
        )
        [ Elm.int fromSecondsArg_ ]


{-| Extracts the hours from a Time

    time (12, 30, 5)
        |> hours
    --> 12

hours: Hour.Time -> Int
-}
hours : Elm.Expression -> Elm.Expression
hours hoursArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "hours"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Time" [] ]
                          Type.int
                     )
             }
        )
        [ hoursArg_ ]


{-| Extracts the minutes from a Time

    time (12, 30, 5)
            |> minutes
        --> 30

minutes: Hour.Time -> Int
-}
minutes : Elm.Expression -> Elm.Expression
minutes minutesArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "minutes"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Time" [] ]
                          Type.int
                     )
             }
        )
        [ minutesArg_ ]


{-| Extracts the seconds from a Time

    time (12, 30, 5)
            |> seconds
        --> 5

seconds: Hour.Time -> Int
-}
seconds : Elm.Expression -> Elm.Expression
seconds secondsArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "seconds"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Time" [] ]
                          Type.int
                     )
             }
        )
        [ secondsArg_ ]


{-| Extracts the milliseconds from a Time

    fromParts {hours = 12, minutes = 30, seconds = 5, millis = 500}
            |> millis
        --> 500

millis: Hour.Time -> Int
-}
millis : Elm.Expression -> Elm.Expression
millis millisArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "millis"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Time" [] ]
                          Type.int
                     )
             }
        )
        [ millisArg_ ]


{-| Extracts all components of a Time as a record

    fromParts {hours = 12, minutes = 30, seconds = 5, millis = 500}
            |> parts
        --> {hours = 12, minutes = 30, seconds = 5, millis = 500}

parts: Hour.Time -> { hours : Int, minutes : Int, seconds : Int, millis : Int }
-}
parts : Elm.Expression -> Elm.Expression
parts partsArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "parts"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Time" [] ]
                          (Type.record
                               [ ( "hours", Type.int )
                               , ( "minutes", Type.int )
                               , ( "seconds", Type.int )
                               , ( "millis", Type.int )
                               ]
                          )
                     )
             }
        )
        [ partsArg_ ]


{-| Converts a Time to ISO 8601 strings.

Times are rendered as "HH:MM:SS.mmm", where the seconds and milliseconds parts
are ommited if possible.

    time (12, 30, 5)
        |> toIsoString
    --> "12:30:05"

    time (12, 30, 0)
        |> toIsoString
    --> "12:30"

toIsoString: Hour.Time -> String
-}
toIsoString : Elm.Expression -> Elm.Expression
toIsoString toIsoStringArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "toIsoString"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Time" [] ]
                          Type.string
                     )
             }
        )
        [ toIsoStringArg_ ]


{-| Convert time to milliseconds ellapsed from the start of the day

    fromParts {hours = 1, minutes = 0, seconds = 1, millis = 500}
        |> toMillis
    --> 3601500

toMillis: Hour.Time -> Int
-}
toMillis : Elm.Expression -> Elm.Expression
toMillis toMillisArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "toMillis"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Time" [] ]
                          Type.int
                     )
             }
        )
        [ toMillisArg_ ]


{-| Convert time to seconds ellapsed from the start of the day

    fromParts {hours = 1, minutes = 0, seconds = 1, millis = 500}
        |> toSeconds
    --> 3601

toSeconds: Hour.Time -> Int
-}
toSeconds : Elm.Expression -> Elm.Expression
toSeconds toSecondsArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "toSeconds"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Time" [] ]
                          Type.int
                     )
             }
        )
        [ toSecondsArg_ ]


{-| Format a time using a string as a template.

    format "EEEE, d MMMM y" (fromOrdinalDate 1970 1)
        == "Thursday, 1 January 1970"

Alphabetic characters in the template represent time information; the number of
times a character is repeated specifies the form of a name or the padding of a number.

Alphabetic characters can be escaped within single-quotes; a single-quote can
be escaped as a sequence of two single-quotes, whether appearing inside or
outside an escaped sequence.

Templates are based on Date Format Patterns in [Unicode Technical Standard #35](https://www.unicode.org/reports/tr35/tr35-43/tr35-dates.html#Date_Format_Patterns).
Only the following subset of formatting characters are available:

    ```
    "h" -- The hour, using a 12-hour clock from 1 to 12.
    "hh" -- The hour, using a 12-hour clock from 01 to 12.
    "H" -- The hour, using a 24-hour clock from 0 to 23.
    "HH" -- The hour, using a 24-hour clock from 00 to 23.
    "m" -- The minute, from 0 through 59.
    "mm" -- The minute, from 00 through 59.
    "s" -- The second, from 0 through 59.
    "ss" -- The second, from 00 through 59.
    "a" -- The first character of the AM/PM designator.
    "aa" -- The AM/PM designator.
    "f" -- The tenths of a second in a date and time value.
    "ff" -- The hundredths of a second in a date and time value.
    "fff" -- The milliseconds in a date and time value.
    ```

    format "hh:mmaa 'and' s 'seconds'" (time (13, 15, 42))
        --> "01:15pm. and 42 seconds"

format: String -> Hour.Time -> String
-}
format : String -> Elm.Expression -> Elm.Expression
format formatArg_ formatArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "format"
             , annotation =
                 Just
                     (Type.function
                          [ Type.string, Type.namedWith [ "Hour" ] "Time" [] ]
                          Type.string
                     )
             }
        )
        [ Elm.string formatArg_, formatArg_0 ]


{-| Format a time using a string as a template, with a specific language.

formatWithLanguage: Hour.Language -> String -> Hour.Time -> String
-}
formatWithLanguage :
    Elm.Expression -> String -> Elm.Expression -> Elm.Expression
formatWithLanguage formatWithLanguageArg_ formatWithLanguageArg_0 formatWithLanguageArg_1 =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "formatWithLanguage"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Language" []
                          , Type.string
                          , Type.namedWith [ "Hour" ] "Time" []
                          ]
                          Type.string
                     )
             }
        )
        [ formatWithLanguageArg_
        , Elm.string formatWithLanguageArg_0
        , formatWithLanguageArg_1
        ]


{-| Get past or future time by adding a number of units to it.

    time ( 9, 0, 0 )
        |> add Hours 1
        |> toIsoString
    --> "10:00"

add: Hour.Unit -> Int -> Hour.Time -> Hour.Time
-}
add : Elm.Expression -> Int -> Elm.Expression -> Elm.Expression
add addArg_ addArg_0 addArg_1 =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "add"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Unit" []
                          , Type.int
                          , Type.namedWith [ "Hour" ] "Time" []
                          ]
                          (Type.namedWith [ "Hour" ] "Time" [])
                     )
             }
        )
        [ addArg_, Elm.int addArg_0, addArg_1 ]


{-| Get the difference between two times, as a number of whole units.

    diff Minutes
        (time ( 10, 0, 0 ))
        (time ( 8, 0, 0 ))
        --> 120

diff: Hour.Unit -> Hour.Time -> Hour.Time -> Int
-}
diff : Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
diff diffArg_ diffArg_0 diffArg_1 =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "diff"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Unit" []
                          , Type.namedWith [ "Hour" ] "Time" []
                          , Type.namedWith [ "Hour" ] "Time" []
                          ]
                          Type.int
                     )
             }
        )
        [ diffArg_, diffArg_0, diffArg_1 ]


{-| Round up a time to the beginning of the closest interval.

The resulting time will be greater than or equal to the one provided.

Any fractional time will be rounded up to the next whole interval.

    time ( 9, 0, 1 )
        |> Hour.ceiling Hour
        |> toIsoString
    --> "10:00"

But exact times will be unchanged:

    time ( 9, 0, 0 )
        |> Hour.ceiling Hour
        |> toIsoString
    --> "09:00"

ceiling: Hour.Interval -> Hour.Time -> Hour.Time
-}
ceiling : Elm.Expression -> Elm.Expression -> Elm.Expression
ceiling ceilingArg_ ceilingArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "ceiling"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Interval" []
                          , Type.namedWith [ "Hour" ] "Time" []
                          ]
                          (Type.namedWith [ "Hour" ] "Time" [])
                     )
             }
        )
        [ ceilingArg_, ceilingArg_0 ]


{-| Round down a time to the beginning of the closest interval.

The resulting time will be less than or equal to the one provided.

    time ( 9, 20, 1 )
        |> Hour.floor Quarter
        |> toIsoString
    --> "09:15"

floor: Hour.Interval -> Hour.Time -> Hour.Time
-}
floor : Elm.Expression -> Elm.Expression -> Elm.Expression
floor floorArg_ floorArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "floor"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Interval" []
                          , Type.namedWith [ "Hour" ] "Time" []
                          ]
                          (Type.namedWith [ "Hour" ] "Time" [])
                     )
             }
        )
        [ floorArg_, floorArg_0 ]


{-| Create a list of times, at rounded intervals, increasing by a step value,
between two times.

The list will start on or after the first time, and end before the second time.

    range Half 3 (time ( 9, 0, 0 )) (time ( 17, 0, 0 ))
        |> List.map toIsoString
        --> [ "09:00", "10:30", "12:00", "13:30", "15:00", "16:30" ]

Notice the final time is not present in the list.

range: Hour.Interval -> Int -> Hour.Time -> Hour.Time -> List Hour.Time
-}
range :
    Elm.Expression -> Int -> Elm.Expression -> Elm.Expression -> Elm.Expression
range rangeArg_ rangeArg_0 rangeArg_1 rangeArg_2 =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "range"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Interval" []
                          , Type.int
                          , Type.namedWith [ "Hour" ] "Time" []
                          , Type.namedWith [ "Hour" ] "Time" []
                          ]
                          (Type.list (Type.namedWith [ "Hour" ] "Time" []))
                     )
             }
        )
        [ rangeArg_, Elm.int rangeArg_0, rangeArg_1, rangeArg_2 ]


{-| Compare two times. This can be used as the compare function for List.sortWith

    List.sortWith Hour.compare [ time ( 9, 0, 0 ), time ( 8, 0, 0 ) ]
        |> List.map toIsoString
    --> [ "08:00", "09:00" ]

compare: Hour.Time -> Hour.Time -> Basics.Order
-}
compare : Elm.Expression -> Elm.Expression -> Elm.Expression
compare compareArg_ compareArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "compare"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Time" []
                          , Type.namedWith [ "Hour" ] "Time" []
                          ]
                          (Type.namedWith [ "Basics" ] "Order" [])
                     )
             }
        )
        [ compareArg_, compareArg_0 ]


{-| Test if a time is within a range, inclusive, of the range values.

    time ( 8, 30, 0 )
        |> isBetween (time ( 8, 0, 0 )) (time ( 9, 0, 0 ))
    --> True

isBetween: Hour.Time -> Hour.Time -> Hour.Time -> Bool
-}
isBetween : Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
isBetween isBetweenArg_ isBetweenArg_0 isBetweenArg_1 =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "isBetween"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Time" []
                          , Type.namedWith [ "Hour" ] "Time" []
                          , Type.namedWith [ "Hour" ] "Time" []
                          ]
                          Type.bool
                     )
             }
        )
        [ isBetweenArg_, isBetweenArg_0, isBetweenArg_1 ]


{-| Get the smaller of two times.

    Hour.min (time ( 8, 0, 0 )) (time ( 9, 0, 0 ))
        |> toIsoString
    --> "08:00"

min: Hour.Time -> Hour.Time -> Hour.Time
-}
min : Elm.Expression -> Elm.Expression -> Elm.Expression
min minArg_ minArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "min"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Time" []
                          , Type.namedWith [ "Hour" ] "Time" []
                          ]
                          (Type.namedWith [ "Hour" ] "Time" [])
                     )
             }
        )
        [ minArg_, minArg_0 ]


{-| Get the larger of two times.

    Hour.max (time ( 8, 0, 0 )) (time ( 9, 0, 0 ))
        |> toIsoString
    --> "09:00"

max: Hour.Time -> Hour.Time -> Hour.Time
-}
max : Elm.Expression -> Elm.Expression -> Elm.Expression
max maxArg_ maxArg_0 =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "max"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Time" []
                          , Type.namedWith [ "Hour" ] "Time" []
                          ]
                          (Type.namedWith [ "Hour" ] "Time" [])
                     )
             }
        )
        [ maxArg_, maxArg_0 ]


{-| Clamp a time within a range.

    clamp start end appointment
        (time ( 9, 0, 0 )) -- start
        (time ( 17, 0, 0 )) -- end
        (time ( 18, 0, 0 )) -- appointment
        |> toIsoString
    -- 17:00:00

clamp: Hour.Time -> Hour.Time -> Hour.Time -> Hour.Time
-}
clamp : Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
clamp clampArg_ clampArg_0 clampArg_1 =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "clamp"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Time" []
                          , Type.namedWith [ "Hour" ] "Time" []
                          , Type.namedWith [ "Hour" ] "Time" []
                          ]
                          (Type.namedWith [ "Hour" ] "Time" [])
                     )
             }
        )
        [ clampArg_, clampArg_0, clampArg_1 ]


{-| JSON decoder for Time

decoder: Json.Decode.Decoder Hour.Time
-}
decoder : Elm.Expression
decoder =
    Elm.value
        { importFrom = [ "Hour" ]
        , name = "decoder"
        , annotation =
            Just
                (Type.namedWith
                     [ "Json", "Decode" ]
                     "Decoder"
                     [ Type.namedWith [ "Hour" ] "Time" [] ]
                )
        }


{-| JSON encoder for Time

encode: Hour.Time -> Json.Encode.Value
-}
encode : Elm.Expression -> Elm.Expression
encode encodeArg_ =
    Elm.apply
        (Elm.value
             { importFrom = [ "Hour" ]
             , name = "encode"
             , annotation =
                 Just
                     (Type.function
                          [ Type.namedWith [ "Hour" ] "Time" [] ]
                          (Type.namedWith [ "Json", "Encode" ] "Value" [])
                     )
             }
        )
        [ encodeArg_ ]


annotation_ :
    { time : Type.Annotation
    , language : Type.Annotation
    , unit : Type.Annotation
    , interval : Type.Annotation
    }
annotation_ =
    { time = Type.namedWith [ "Hour" ] "Time" []
    , language =
        Type.alias
            moduleName_
            "Language"
            []
            (Type.record [ ( "am", Type.string ), ( "pm", Type.string ) ])
    , unit = Type.namedWith [ "Hour" ] "Unit" []
    , interval = Type.namedWith [ "Hour" ] "Interval" []
    }


make_ :
    { t : Elm.Expression -> Elm.Expression
    , language : { am : Elm.Expression, pm : Elm.Expression } -> Elm.Expression
    , hours : Elm.Expression
    , minutes : Elm.Expression
    , seconds : Elm.Expression
    , milliseconds : Elm.Expression
    , hour : Elm.Expression
    , half : Elm.Expression
    , quarter : Elm.Expression
    , minute : Elm.Expression
    , second : Elm.Expression
    , millisecond : Elm.Expression
    }
make_ =
    { t =
        \ar0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "T"
                     , annotation = Just (Type.namedWith [ "Hour" ] "Time" [])
                     }
                )
                [ ar0 ]
    , language =
        \language_args ->
            Elm.withType
                (Type.alias
                     [ "Hour" ]
                     "Language"
                     []
                     (Type.record
                          [ ( "am", Type.string ), ( "pm", Type.string ) ]
                     )
                )
                (Elm.record
                     [ Tuple.pair "am" language_args.am
                     , Tuple.pair "pm" language_args.pm
                     ]
                )
    , hours =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "Hours"
            , annotation = Just (Type.namedWith [ "Hour" ] "Unit" [])
            }
    , minutes =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "Minutes"
            , annotation = Just (Type.namedWith [ "Hour" ] "Unit" [])
            }
    , seconds =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "Seconds"
            , annotation = Just (Type.namedWith [ "Hour" ] "Unit" [])
            }
    , milliseconds =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "Milliseconds"
            , annotation = Just (Type.namedWith [ "Hour" ] "Unit" [])
            }
    , hour =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "Hour"
            , annotation = Just (Type.namedWith [ "Hour" ] "Interval" [])
            }
    , half =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "Half"
            , annotation = Just (Type.namedWith [ "Hour" ] "Interval" [])
            }
    , quarter =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "Quarter"
            , annotation = Just (Type.namedWith [ "Hour" ] "Interval" [])
            }
    , minute =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "Minute"
            , annotation = Just (Type.namedWith [ "Hour" ] "Interval" [])
            }
    , second =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "Second"
            , annotation = Just (Type.namedWith [ "Hour" ] "Interval" [])
            }
    , millisecond =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "Millisecond"
            , annotation = Just (Type.namedWith [ "Hour" ] "Interval" [])
            }
    }


caseOf_ :
    { time :
        Elm.Expression
        -> { t : Elm.Expression -> Elm.Expression }
        -> Elm.Expression
    , unit :
        Elm.Expression
        -> { hours : Elm.Expression
        , minutes : Elm.Expression
        , seconds : Elm.Expression
        , milliseconds : Elm.Expression
        }
        -> Elm.Expression
    , interval :
        Elm.Expression
        -> { hour : Elm.Expression
        , half : Elm.Expression
        , quarter : Elm.Expression
        , minute : Elm.Expression
        , second : Elm.Expression
        , millisecond : Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { time =
        \timeExpression timeTags ->
            Elm.Case.custom
                timeExpression
                (Type.namedWith [ "Hour" ] "Time" [])
                [ Elm.Case.branch
                    (Elm.Arg.customType "T" timeTags.t |> Elm.Arg.item
                                                                (Elm.Arg.varWith
                                                                       "arg_0"
                                                                       (Type.record
                                                                              [ ( "hours"
                                                                                , Type.int
                                                                                )
                                                                              , ( "minutes"
                                                                                , Type.int
                                                                                )
                                                                              , ( "seconds"
                                                                                , Type.int
                                                                                )
                                                                              , ( "millis"
                                                                                , Type.int
                                                                                )
                                                                              ]
                                                                       )
                                                                )
                    )
                    Basics.identity
                ]
    , unit =
        \unitExpression unitTags ->
            Elm.Case.custom
                unitExpression
                (Type.namedWith [ "Hour" ] "Unit" [])
                [ Elm.Case.branch
                    (Elm.Arg.customType "Hours" unitTags.hours)
                    Basics.identity
                , Elm.Case.branch
                    (Elm.Arg.customType "Minutes" unitTags.minutes)
                    Basics.identity
                , Elm.Case.branch
                    (Elm.Arg.customType "Seconds" unitTags.seconds)
                    Basics.identity
                , Elm.Case.branch
                    (Elm.Arg.customType "Milliseconds" unitTags.milliseconds)
                    Basics.identity
                ]
    , interval =
        \intervalExpression intervalTags ->
            Elm.Case.custom
                intervalExpression
                (Type.namedWith [ "Hour" ] "Interval" [])
                [ Elm.Case.branch
                    (Elm.Arg.customType "Hour" intervalTags.hour)
                    Basics.identity
                , Elm.Case.branch
                    (Elm.Arg.customType "Half" intervalTags.half)
                    Basics.identity
                , Elm.Case.branch
                    (Elm.Arg.customType "Quarter" intervalTags.quarter)
                    Basics.identity
                , Elm.Case.branch
                    (Elm.Arg.customType "Minute" intervalTags.minute)
                    Basics.identity
                , Elm.Case.branch
                    (Elm.Arg.customType "Second" intervalTags.second)
                    Basics.identity
                , Elm.Case.branch
                    (Elm.Arg.customType "Millisecond" intervalTags.millisecond)
                    Basics.identity
                ]
    }


call_ :
    { time : Elm.Expression -> Elm.Expression
    , fromParts : Elm.Expression -> Elm.Expression
    , fromPosix : Elm.Expression -> Elm.Expression -> Elm.Expression
    , fromIsoString : Elm.Expression -> Elm.Expression
    , fromMillis : Elm.Expression -> Elm.Expression
    , fromSeconds : Elm.Expression -> Elm.Expression
    , hours : Elm.Expression -> Elm.Expression
    , minutes : Elm.Expression -> Elm.Expression
    , seconds : Elm.Expression -> Elm.Expression
    , millis : Elm.Expression -> Elm.Expression
    , parts : Elm.Expression -> Elm.Expression
    , toIsoString : Elm.Expression -> Elm.Expression
    , toMillis : Elm.Expression -> Elm.Expression
    , toSeconds : Elm.Expression -> Elm.Expression
    , format : Elm.Expression -> Elm.Expression -> Elm.Expression
    , formatWithLanguage :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , add : Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , diff :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , ceiling : Elm.Expression -> Elm.Expression -> Elm.Expression
    , floor : Elm.Expression -> Elm.Expression -> Elm.Expression
    , range :
        Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
    , compare : Elm.Expression -> Elm.Expression -> Elm.Expression
    , isBetween :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , min : Elm.Expression -> Elm.Expression -> Elm.Expression
    , max : Elm.Expression -> Elm.Expression -> Elm.Expression
    , clamp :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , encode : Elm.Expression -> Elm.Expression
    }
call_ =
    { time =
        \timeArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "time"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.triple Type.int Type.int Type.int ]
                                  (Type.namedWith [ "Hour" ] "Time" [])
                             )
                     }
                )
                [ timeArg_ ]
    , fromParts =
        \fromPartsArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "fromParts"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.record
                                      [ ( "hours", Type.int )
                                      , ( "minutes", Type.int )
                                      , ( "seconds", Type.int )
                                      , ( "millis", Type.int )
                                      ]
                                  ]
                                  (Type.namedWith [ "Hour" ] "Time" [])
                             )
                     }
                )
                [ fromPartsArg_ ]
    , fromPosix =
        \fromPosixArg_ fromPosixArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "fromPosix"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Time" ] "Zone" []
                                  , Type.namedWith [ "Time" ] "Posix" []
                                  ]
                                  (Type.namedWith [ "Hour" ] "Time" [])
                             )
                     }
                )
                [ fromPosixArg_, fromPosixArg_0 ]
    , fromIsoString =
        \fromIsoStringArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "fromIsoString"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.string ]
                                  (Type.maybe
                                       (Type.namedWith [ "Hour" ] "Time" [])
                                  )
                             )
                     }
                )
                [ fromIsoStringArg_ ]
    , fromMillis =
        \fromMillisArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "fromMillis"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.int ]
                                  (Type.namedWith [ "Hour" ] "Time" [])
                             )
                     }
                )
                [ fromMillisArg_ ]
    , fromSeconds =
        \fromSecondsArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "fromSeconds"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.int ]
                                  (Type.namedWith [ "Hour" ] "Time" [])
                             )
                     }
                )
                [ fromSecondsArg_ ]
    , hours =
        \hoursArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "hours"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Time" [] ]
                                  Type.int
                             )
                     }
                )
                [ hoursArg_ ]
    , minutes =
        \minutesArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "minutes"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Time" [] ]
                                  Type.int
                             )
                     }
                )
                [ minutesArg_ ]
    , seconds =
        \secondsArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "seconds"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Time" [] ]
                                  Type.int
                             )
                     }
                )
                [ secondsArg_ ]
    , millis =
        \millisArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "millis"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Time" [] ]
                                  Type.int
                             )
                     }
                )
                [ millisArg_ ]
    , parts =
        \partsArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "parts"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Time" [] ]
                                  (Type.record
                                       [ ( "hours", Type.int )
                                       , ( "minutes", Type.int )
                                       , ( "seconds", Type.int )
                                       , ( "millis", Type.int )
                                       ]
                                  )
                             )
                     }
                )
                [ partsArg_ ]
    , toIsoString =
        \toIsoStringArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "toIsoString"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Time" [] ]
                                  Type.string
                             )
                     }
                )
                [ toIsoStringArg_ ]
    , toMillis =
        \toMillisArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "toMillis"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Time" [] ]
                                  Type.int
                             )
                     }
                )
                [ toMillisArg_ ]
    , toSeconds =
        \toSecondsArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "toSeconds"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Time" [] ]
                                  Type.int
                             )
                     }
                )
                [ toSecondsArg_ ]
    , format =
        \formatArg_ formatArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "format"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.string
                                  , Type.namedWith [ "Hour" ] "Time" []
                                  ]
                                  Type.string
                             )
                     }
                )
                [ formatArg_, formatArg_0 ]
    , formatWithLanguage =
        \formatWithLanguageArg_ formatWithLanguageArg_0 formatWithLanguageArg_1 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "formatWithLanguage"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Language" []
                                  , Type.string
                                  , Type.namedWith [ "Hour" ] "Time" []
                                  ]
                                  Type.string
                             )
                     }
                )
                [ formatWithLanguageArg_
                , formatWithLanguageArg_0
                , formatWithLanguageArg_1
                ]
    , add =
        \addArg_ addArg_0 addArg_1 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "add"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Unit" []
                                  , Type.int
                                  , Type.namedWith [ "Hour" ] "Time" []
                                  ]
                                  (Type.namedWith [ "Hour" ] "Time" [])
                             )
                     }
                )
                [ addArg_, addArg_0, addArg_1 ]
    , diff =
        \diffArg_ diffArg_0 diffArg_1 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "diff"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Unit" []
                                  , Type.namedWith [ "Hour" ] "Time" []
                                  , Type.namedWith [ "Hour" ] "Time" []
                                  ]
                                  Type.int
                             )
                     }
                )
                [ diffArg_, diffArg_0, diffArg_1 ]
    , ceiling =
        \ceilingArg_ ceilingArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "ceiling"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Interval" []
                                  , Type.namedWith [ "Hour" ] "Time" []
                                  ]
                                  (Type.namedWith [ "Hour" ] "Time" [])
                             )
                     }
                )
                [ ceilingArg_, ceilingArg_0 ]
    , floor =
        \floorArg_ floorArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "floor"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Interval" []
                                  , Type.namedWith [ "Hour" ] "Time" []
                                  ]
                                  (Type.namedWith [ "Hour" ] "Time" [])
                             )
                     }
                )
                [ floorArg_, floorArg_0 ]
    , range =
        \rangeArg_ rangeArg_0 rangeArg_1 rangeArg_2 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "range"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Interval" []
                                  , Type.int
                                  , Type.namedWith [ "Hour" ] "Time" []
                                  , Type.namedWith [ "Hour" ] "Time" []
                                  ]
                                  (Type.list
                                       (Type.namedWith [ "Hour" ] "Time" [])
                                  )
                             )
                     }
                )
                [ rangeArg_, rangeArg_0, rangeArg_1, rangeArg_2 ]
    , compare =
        \compareArg_ compareArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "compare"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Time" []
                                  , Type.namedWith [ "Hour" ] "Time" []
                                  ]
                                  (Type.namedWith [ "Basics" ] "Order" [])
                             )
                     }
                )
                [ compareArg_, compareArg_0 ]
    , isBetween =
        \isBetweenArg_ isBetweenArg_0 isBetweenArg_1 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "isBetween"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Time" []
                                  , Type.namedWith [ "Hour" ] "Time" []
                                  , Type.namedWith [ "Hour" ] "Time" []
                                  ]
                                  Type.bool
                             )
                     }
                )
                [ isBetweenArg_, isBetweenArg_0, isBetweenArg_1 ]
    , min =
        \minArg_ minArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "min"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Time" []
                                  , Type.namedWith [ "Hour" ] "Time" []
                                  ]
                                  (Type.namedWith [ "Hour" ] "Time" [])
                             )
                     }
                )
                [ minArg_, minArg_0 ]
    , max =
        \maxArg_ maxArg_0 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "max"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Time" []
                                  , Type.namedWith [ "Hour" ] "Time" []
                                  ]
                                  (Type.namedWith [ "Hour" ] "Time" [])
                             )
                     }
                )
                [ maxArg_, maxArg_0 ]
    , clamp =
        \clampArg_ clampArg_0 clampArg_1 ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "clamp"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Time" []
                                  , Type.namedWith [ "Hour" ] "Time" []
                                  , Type.namedWith [ "Hour" ] "Time" []
                                  ]
                                  (Type.namedWith [ "Hour" ] "Time" [])
                             )
                     }
                )
                [ clampArg_, clampArg_0, clampArg_1 ]
    , encode =
        \encodeArg_ ->
            Elm.apply
                (Elm.value
                     { importFrom = [ "Hour" ]
                     , name = "encode"
                     , annotation =
                         Just
                             (Type.function
                                  [ Type.namedWith [ "Hour" ] "Time" [] ]
                                  (Type.namedWith
                                       [ "Json", "Encode" ]
                                       "Value"
                                       []
                                  )
                             )
                     }
                )
                [ encodeArg_ ]
    }


values_ :
    { now : Elm.Expression
    , time : Elm.Expression
    , fromParts : Elm.Expression
    , fromPosix : Elm.Expression
    , fromIsoString : Elm.Expression
    , fromMillis : Elm.Expression
    , fromSeconds : Elm.Expression
    , hours : Elm.Expression
    , minutes : Elm.Expression
    , seconds : Elm.Expression
    , millis : Elm.Expression
    , parts : Elm.Expression
    , toIsoString : Elm.Expression
    , toMillis : Elm.Expression
    , toSeconds : Elm.Expression
    , format : Elm.Expression
    , formatWithLanguage : Elm.Expression
    , add : Elm.Expression
    , diff : Elm.Expression
    , ceiling : Elm.Expression
    , floor : Elm.Expression
    , range : Elm.Expression
    , compare : Elm.Expression
    , isBetween : Elm.Expression
    , min : Elm.Expression
    , max : Elm.Expression
    , clamp : Elm.Expression
    , decoder : Elm.Expression
    , encode : Elm.Expression
    }
values_ =
    { now =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "now"
            , annotation =
                Just
                    (Type.namedWith
                         [ "Task" ]
                         "Task"
                         [ Type.var "x", Type.namedWith [ "Hour" ] "Time" [] ]
                    )
            }
    , time =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "time"
            , annotation =
                Just
                    (Type.function
                         [ Type.triple Type.int Type.int Type.int ]
                         (Type.namedWith [ "Hour" ] "Time" [])
                    )
            }
    , fromParts =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "fromParts"
            , annotation =
                Just
                    (Type.function
                         [ Type.record
                             [ ( "hours", Type.int )
                             , ( "minutes", Type.int )
                             , ( "seconds", Type.int )
                             , ( "millis", Type.int )
                             ]
                         ]
                         (Type.namedWith [ "Hour" ] "Time" [])
                    )
            }
    , fromPosix =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "fromPosix"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Time" ] "Zone" []
                         , Type.namedWith [ "Time" ] "Posix" []
                         ]
                         (Type.namedWith [ "Hour" ] "Time" [])
                    )
            }
    , fromIsoString =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "fromIsoString"
            , annotation =
                Just
                    (Type.function
                         [ Type.string ]
                         (Type.maybe (Type.namedWith [ "Hour" ] "Time" []))
                    )
            }
    , fromMillis =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "fromMillis"
            , annotation =
                Just
                    (Type.function
                         [ Type.int ]
                         (Type.namedWith [ "Hour" ] "Time" [])
                    )
            }
    , fromSeconds =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "fromSeconds"
            , annotation =
                Just
                    (Type.function
                         [ Type.int ]
                         (Type.namedWith [ "Hour" ] "Time" [])
                    )
            }
    , hours =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "hours"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Time" [] ]
                         Type.int
                    )
            }
    , minutes =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "minutes"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Time" [] ]
                         Type.int
                    )
            }
    , seconds =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "seconds"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Time" [] ]
                         Type.int
                    )
            }
    , millis =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "millis"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Time" [] ]
                         Type.int
                    )
            }
    , parts =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "parts"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Time" [] ]
                         (Type.record
                              [ ( "hours", Type.int )
                              , ( "minutes", Type.int )
                              , ( "seconds", Type.int )
                              , ( "millis", Type.int )
                              ]
                         )
                    )
            }
    , toIsoString =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "toIsoString"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Time" [] ]
                         Type.string
                    )
            }
    , toMillis =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "toMillis"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Time" [] ]
                         Type.int
                    )
            }
    , toSeconds =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "toSeconds"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Time" [] ]
                         Type.int
                    )
            }
    , format =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "format"
            , annotation =
                Just
                    (Type.function
                         [ Type.string, Type.namedWith [ "Hour" ] "Time" [] ]
                         Type.string
                    )
            }
    , formatWithLanguage =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "formatWithLanguage"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Language" []
                         , Type.string
                         , Type.namedWith [ "Hour" ] "Time" []
                         ]
                         Type.string
                    )
            }
    , add =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "add"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Unit" []
                         , Type.int
                         , Type.namedWith [ "Hour" ] "Time" []
                         ]
                         (Type.namedWith [ "Hour" ] "Time" [])
                    )
            }
    , diff =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "diff"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Unit" []
                         , Type.namedWith [ "Hour" ] "Time" []
                         , Type.namedWith [ "Hour" ] "Time" []
                         ]
                         Type.int
                    )
            }
    , ceiling =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "ceiling"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Interval" []
                         , Type.namedWith [ "Hour" ] "Time" []
                         ]
                         (Type.namedWith [ "Hour" ] "Time" [])
                    )
            }
    , floor =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "floor"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Interval" []
                         , Type.namedWith [ "Hour" ] "Time" []
                         ]
                         (Type.namedWith [ "Hour" ] "Time" [])
                    )
            }
    , range =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "range"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Interval" []
                         , Type.int
                         , Type.namedWith [ "Hour" ] "Time" []
                         , Type.namedWith [ "Hour" ] "Time" []
                         ]
                         (Type.list (Type.namedWith [ "Hour" ] "Time" []))
                    )
            }
    , compare =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "compare"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Time" []
                         , Type.namedWith [ "Hour" ] "Time" []
                         ]
                         (Type.namedWith [ "Basics" ] "Order" [])
                    )
            }
    , isBetween =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "isBetween"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Time" []
                         , Type.namedWith [ "Hour" ] "Time" []
                         , Type.namedWith [ "Hour" ] "Time" []
                         ]
                         Type.bool
                    )
            }
    , min =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "min"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Time" []
                         , Type.namedWith [ "Hour" ] "Time" []
                         ]
                         (Type.namedWith [ "Hour" ] "Time" [])
                    )
            }
    , max =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "max"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Time" []
                         , Type.namedWith [ "Hour" ] "Time" []
                         ]
                         (Type.namedWith [ "Hour" ] "Time" [])
                    )
            }
    , clamp =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "clamp"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Time" []
                         , Type.namedWith [ "Hour" ] "Time" []
                         , Type.namedWith [ "Hour" ] "Time" []
                         ]
                         (Type.namedWith [ "Hour" ] "Time" [])
                    )
            }
    , decoder =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "decoder"
            , annotation =
                Just
                    (Type.namedWith
                         [ "Json", "Decode" ]
                         "Decoder"
                         [ Type.namedWith [ "Hour" ] "Time" [] ]
                    )
            }
    , encode =
        Elm.value
            { importFrom = [ "Hour" ]
            , name = "encode"
            , annotation =
                Just
                    (Type.function
                         [ Type.namedWith [ "Hour" ] "Time" [] ]
                         (Type.namedWith [ "Json", "Encode" ] "Value" [])
                    )
            }
    }