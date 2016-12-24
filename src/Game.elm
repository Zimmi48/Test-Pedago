module Game exposing (..)

import Html exposing (Html)


main =
    Html.beginnerProgram { model = initModel, view = view, update = update }


type alias Question =
    ( Int, Int )


type Nat
    = Zero
    | Succ Nat


type Score
    = RemainingTrials Nat
    | Success
    | Failure


type alias Model =
    { remaining : List Question
    , done : List ( Question, Score )
    , currentQuestion : Question
    , currentScore : Score
    }
