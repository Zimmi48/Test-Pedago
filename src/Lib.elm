module Lib exposing (..)


pureUpdate : (a -> b -> c) -> a -> b -> ( c, Cmd msg )
pureUpdate update msg state =
    update msg state |> pureState
