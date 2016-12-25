module Game exposing (..)

import Html exposing (Html)
import Keyboard exposing (KeyCode)
import Lib exposing (..)
import Process
import Task


main : Program Never State Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions =
            \{ locked } ->
                if locked then
                    Sub.none
                else
                    Keyboard.downs Key
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
    , locked : Bool
    }


init : ( State, Cmd Msg )
init =
    let
        question =
            ( 9, 3, 27 )
    in
        ( { remaining = [ ( 2, 3, 6 ), ( 6, 7, 42 ) ]
          , done = []
          , currentQuestion = question
          , questionState = initQuestionState
          , locked = False
          }
        , setTimeout ( question, initRemainings )
        )


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
    | Unlock
    | TimeOut Id


type alias Id =
    ( Question, Nat )



-- Create a unique id from the question and the remaining trials
-- One must assume that there won't be identical questions in one set
-- TODO: make this impossible


update : Msg -> State -> ( State, Cmd Msg )
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
                        let
                            ( newQuestionState, cmd ) =
                                updateQuestionState state.currentQuestion key r
                        in
                            ( { state | questionState = newQuestionState }, cmd )

                    ( Done points, question, newQuestion :: questions, Enter ) ->
                        ( { state
                            | remaining = questions
                            , done = ( question, points ) :: state.done
                            , currentQuestion = newQuestion
                            , questionState = initQuestionState
                          }
                          -- risk of confusion
                          -- can we make it impossible to give the wrong id
                        , setTimeout ( newQuestion, initRemainings )
                        )

                    _ ->
                        pureState state

        Unlock ->
            { state | locked = False } |> pureState

        TimeOut ( question, nat ) ->
            case ( state.questionState, state.currentQuestion ) of
                ( RemainingTrials ( stateNat, ans ), ( _, _, res ) ) ->
                    if question == state.currentQuestion && nat == stateNat then
                        -- the timeout is valid
                        let
                            ( newQuestionState, cmd ) =
                                checkIfGoodAnswer question nat ans
                        in
                            { state
                                | questionState = newQuestionState
                                , locked =
                                    True
                                    -- we lock for a little while in case the user
                                    -- presses a key just after the timeout
                            }
                                ! [ cmd, unlockCmd ]
                    else
                        -- false alarm
                        pureState state

                _ ->
                    -- false alarm
                    pureState state


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


updateQuestionState : Question -> KeyInterp -> ( Nat, Answer ) -> ( QuestionState, Cmd Msg )
updateQuestionState question key ( nat, answer ) =
    case ( key, nat, answer ) of
        ( Digit d, nat, Nothing ) ->
            RemainingTrials ( nat, Just d )
                |> pureState

        ( Digit d, nat, Just ans ) ->
            RemainingTrials ( nat, Just <| ans * 10 + d )
                |> pureState

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
                |> pureState

        ( Enter, nat, Just ans ) ->
            checkIfGoodAnswer question nat (Just ans)

        _ ->
            RemainingTrials ( nat, answer )
                |> pureState


checkIfGoodAnswer : Question -> Nat -> Maybe Int -> ( QuestionState, Cmd Msg )
checkIfGoodAnswer (( _, _, res ) as question) nat answer =
    let
        badAnswer =
            case nat of
                Zero ->
                    Done 0 |> pureState

                Succ nat ->
                    ( RemainingTrials ( nat, Nothing )
                    , setTimeout ( question, nat )
                    )
    in
        case answer of
            Just ans ->
                if ans == res then
                    Done (computePoints nat) |> pureState
                else
                    badAnswer

            Nothing ->
                badAnswer


computePoints : Nat -> number
computePoints nat =
    case nat of
        Zero ->
            1

        Succ nat ->
            2 * (computePoints nat) + 1



-- Define commands


setTimeout : Id -> Cmd Msg
setTimeout id =
    Process.sleep 10000
        |> Task.perform (always <| TimeOut id)


unlockCmd : Cmd Msg
unlockCmd =
    Process.sleep 500
        |> Task.perform (always Unlock)
