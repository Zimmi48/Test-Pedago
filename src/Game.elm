module Game exposing (..)

import Html exposing (Html)


main : Program Never State msg
main =
    Html.beginnerProgram { model = initState, view = view, update = update }


type alias Question =
    ( Int, Int, Int )


type Nat
    = Zero
    | Succ Nat


toInt : Nat -> number
toInt nat =
    case nat of
        Zero ->
            0

        Succ nat ->
            1 + toInt nat


type QuestionState
    = RemainingTrials Nat
    | Done Int


type alias State =
    { remaining : List Question
    , done : List ( Question, Int )
    , currentQuestion : Question
    , questionState : QuestionState
    }


maxTrials : Nat
maxTrials =
    Succ (Succ Zero)


initState : State
initState =
    { remaining = [ ( 2, 3, 6 ), ( 6, 7, 42 ) ]
    , done = []
    , currentQuestion = ( 9, 3, 27 )
    , questionState = RemainingTrials maxTrials
    }


view : State -> Html msg
view state =
    Html.div []
        [ viewDone state.done
        , viewCurrent state.currentQuestion state.questionState
        , "Questions restantes: "
            ++ (state.remaining |> List.length |> toString)
            |> Html.text
        ]


viewDone : List ( Question, Int ) -> Html msg
viewDone =
    List.map viewDoneQuestion >> Html.ul []


viewDoneQuestion : ( Question, Int ) -> Html msg
viewDoneQuestion ( ( x, y, res ), score ) =
    Html.li []
        [ viewQuestion x y
            ++ toString res
            ++ " : "
            ++ toString score
            ++ " points."
            |> Html.text
        ]


viewCurrent : ( a, b, c ) -> QuestionState -> Html msg
viewCurrent ( x, y, _ ) state =
    Html.div []
        [ Html.div [] [ viewQuestion x y ++ "?" |> Html.text ]
        , Html.div [] [ viewQuestionState state |> Html.text ]
        ]


viewQuestion : a -> b -> String
viewQuestion x y =
    toString x
        ++ " × "
        ++ toString y
        ++ " = "


viewQuestionState : QuestionState -> String
viewQuestionState state =
    case state of
        RemainingTrials nat ->
            (nat |> toInt |> toString) ++ " essais restants."

        Done points ->
            toString points ++ "points."


update : msg -> State -> State
update msg state =
    state
