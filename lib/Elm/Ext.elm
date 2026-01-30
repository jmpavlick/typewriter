module Elm.Ext exposing (..)

import Elm
import Elm.Op


{-| big up leo
-}
pipeline : Elm.Expression -> List (Elm.Expression -> Elm.Expression) -> Elm.Expression
pipeline =
    List.foldl (\e a -> Elm.Op.pipe (Elm.functionReduced "pipeArg__" e) a)
