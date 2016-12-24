module Lib exposing (..)


pureState : a -> ( a, Cmd msg )
pureState state =
    state ! []


pureUpdate : (a -> b -> c) -> a -> b -> ( c, Cmd msg )
pureUpdate update msg state =
    update msg state |> pureState
