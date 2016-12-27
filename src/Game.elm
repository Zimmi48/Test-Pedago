module Main exposing (..)


type QuestionState comparable
    = Done { x : Int }


checkAnswer state =
    if True then
        Done 0
    else
        { x = 0 }


setTimeout : QuestionState -> Cmd msg
setTimeout { x } =
    Cmd.none
