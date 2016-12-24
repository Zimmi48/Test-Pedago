module Game exposing (..)

import Html exposing (Html)
import Keyboard exposing (KeyCode)
import Lib exposing (..)


main : Program Never State Msg
main =
    Html.program
        { init = pureState initState
        , view = view
        , update = pureUpdate update
        , subscriptions =
            \_ -> Keyboard.downs Key
            -- TODO: stop listening to keyboard during one second after change of state
        }


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


type alias Answer =
    Maybe Int


type QuestionState
    = RemainingTrials ( Nat, Answer )
    | Done Int


type alias State =
    { remaining : List Question
    , done : List ( Question, Int )
    , currentQuestion : Question
    , questionState : QuestionState
    }


initState : State
initState =
    { remaining = [ ( 2, 3, 6 ), ( 6, 7, 42 ) ]
    , done = []
    , currentQuestion = ( 9, 3, 27 )
    , questionState = initQuestionState
    }


initQuestionState : QuestionState
initQuestionState =
    RemainingTrials ( initRemainings, Nothing )


initRemainings : Nat
initRemainings =
    Succ Zero


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
viewCurrent ( x, y, res ) state =
    let
        ( info, answer ) =
            viewQuestionState (toString res) state
    in
        Html.div []
            [ Html.div [] [ viewQuestion x y ++ answer |> Html.text ]
            , Html.div [] [ info |> Html.text ]
            ]


viewQuestion : a -> b -> String
viewQuestion x y =
    toString x
        ++ " × "
        ++ toString y
        ++ " = "


viewQuestionState : String -> QuestionState -> ( String, String )
viewQuestionState default state =
    case state of
        RemainingTrials ( nat, answer ) ->
            ( (nat |> toInt |> (+) 1 |> toString) ++ " essais restants."
            , case answer of
                Nothing ->
                    "?"

                Just x ->
                    toString x
            )

        Done points ->
            ( toString points ++ " points.", default )


type Msg
    = Key KeyCode


update : Msg -> State -> State
update msg state =
    case msg of
        Key k ->
            let
                key =
                    keyInterp k
            in
                case
                    ( state.questionState
                    , state.currentQuestion
                    , state.remaining
                    , key
                    )
                of
                    ( RemainingTrials r, ( _, _, res ), _, _ ) ->
                        { state | questionState = updateQuestionState res key r }

                    ( Done points, question, newQuestion :: questions, Enter ) ->
                        { remaining = questions
                        , done = ( question, points ) :: state.done
                        , currentQuestion = newQuestion
                        , questionState = initQuestionState
                        }

                    _ ->
                        state


type KeyInterp
    = Digit Int
    | Enter
    | Backspace
    | Ignore


keyInterp : KeyCode -> KeyInterp
keyInterp key =
    if key >= 48 && key <= 57 then
        Digit (key - 48)
    else if key == 13 then
        Enter
    else if key == 8 then
        Backspace
    else
        Ignore


updateQuestionState : Int -> KeyInterp -> ( Nat, Answer ) -> QuestionState
updateQuestionState res key ( nat, answer ) =
    case ( key, nat, answer ) of
        ( Digit d, nat, Nothing ) ->
            RemainingTrials ( nat, Just d )

        ( Digit d, nat, Just ans ) ->
            RemainingTrials ( nat, Just <| ans * 10 + d )

        ( Backspace, nat, Just ans ) ->
            RemainingTrials
                ( nat
                , let
                    newAns =
                        ans // 10
                  in
                    if newAns == 0 then
                        Nothing
                    else
                        Just newAns
                )

        ( Enter, nat, Just ans ) ->
            if ans == res then
                Done (computePoints nat)
            else
                case nat of
                    Zero ->
                        Done 0

                    Succ nat ->
                        RemainingTrials ( nat, Nothing )

        _ ->
            RemainingTrials ( nat, answer )


computePoints : Nat -> number
computePoints nat =
    case nat of
        Zero ->
            1

        Succ nat ->
            2 * (computePoints nat) + 1
