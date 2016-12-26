module Game exposing (..)

import Html exposing (Html)
import Keyboard exposing (KeyCode)
import Lib exposing (..)
import Process
import Task


main : Program Never (State ( Int, Int )) (Msg ( Int, Int ))
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Config question =
    { timeout : Int
    , answerOf : question -> String
    , viewQuestion : question -> String
    }


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
    Maybe String


type QuestionState
    = RemainingTrials ( Nat, Answer )
    | Done Int


type alias State question =
    { remaining : List question
    , done : List ( question, Int )
    , currentQuestion : question
    , questionState : QuestionState
    , locked : Bool
    , config : Config question
    }


init : ( State ( Int, Int ), Cmd (Msg ( Int, Int )) )
init =
    let
        question =
            ( 9, 3 )

        config =
            { timeout = 5
            , answerOf = \( x, y ) -> toString (x * y)
            , viewQuestion =
                \( x, y ) -> toString x ++ " × " ++ toString y ++ " = "
            }
    in
        ( { remaining = [ ( 2, 3 ), ( 6, 7 ) ]
          , done = []
          , currentQuestion = question
          , questionState = initQuestionState
          , locked = False
          , config = config
          }
        , setTimeout config ( question, initRemainings )
        )


initQuestionState : QuestionState
initQuestionState =
    RemainingTrials ( initRemainings, Nothing )


initRemainings : Nat
initRemainings =
    Succ Zero


view : State question -> Html msg
view state =
    Html.div []
        [ viewDone state.config state.done
        , viewCurrent state.config state.currentQuestion state.questionState
        , "Questions restantes: "
            ++ (state.remaining |> List.length |> toString)
            |> Html.text
        ]


viewDone : Config question -> List ( question, Int ) -> Html msg
viewDone config =
    List.map (viewDoneQuestion config) >> Html.ul []


viewDoneQuestion : Config question -> ( question, Int ) -> Html msg
viewDoneQuestion config ( question, score ) =
    Html.li []
        [ config.viewQuestion question
            ++ config.answerOf question
            ++ " : "
            ++ toString score
            ++ " points."
            |> Html.text
        ]


viewCurrent : Config question -> question -> QuestionState -> Html msg
viewCurrent config question state =
    let
        ( info, currentAnswer ) =
            viewQuestionState (config.answerOf question) state
    in
        Html.div []
            [ Html.div []
                [ config.viewQuestion question
                    ++ currentAnswer
                    |> Html.text
                ]
            , Html.div [] [ info |> Html.text ]
            ]


viewQuestionState : String -> QuestionState -> ( String, String )
viewQuestionState default state =
    case state of
        RemainingTrials ( nat, answer ) ->
            ( (nat |> toInt |> (+) 1 |> toString) ++ " essais restants."
            , answer |> Maybe.withDefault "?"
            )

        Done points ->
            ( toString points ++ " points.", default )


type Msg question
    = Key KeyCode
    | Unlock
    | TimeOut (Id question)


type alias Id question =
    ( question, Nat )



-- Create a unique id from the question and the remaining trials
-- One must assume that there won't be identical questions in one set
-- TODO: make this impossible


update : Msg question -> State question -> ( State question, Cmd (Msg question) )
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
                    ( RemainingTrials r, _, _, _ ) ->
                        let
                            ( newQuestionState, cmd ) =
                                updateQuestionState
                                    state.config
                                    state.currentQuestion
                                    key
                                    r
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
                        , setTimeout state.config ( newQuestion, initRemainings )
                        )

                    _ ->
                        pureState state

        Unlock ->
            { state | locked = False } |> pureState

        TimeOut ( question, nat ) ->
            case state.questionState of
                RemainingTrials ( stateNat, ans ) ->
                    if question == state.currentQuestion && nat == stateNat then
                        -- the timeout is valid
                        let
                            ( newQuestionState, cmd ) =
                                checkIfGoodAnswer state.config question nat ans
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


updateQuestionState :
    Config question
    -> question
    -> KeyInterp
    -> ( Nat, Answer )
    -> ( QuestionState, Cmd (Msg question) )
updateQuestionState config question key ( nat, answer ) =
    case ( key, nat, answer ) of
        ( Digit d, nat, Nothing ) ->
            RemainingTrials ( nat, d |> toString |> Just )
                |> pureState

        ( Digit d, nat, Just "0" ) ->
            RemainingTrials ( nat, d |> toString |> Just )
                |> pureState

        ( Digit d, nat, Just ans ) ->
            RemainingTrials ( nat, ans ++ toString d |> Just )
                |> pureState

        ( Backspace, nat, Just ans ) ->
            RemainingTrials
                ( nat
                , let
                    newAns =
                        String.dropRight 1 ans
                  in
                    if String.isEmpty newAns then
                        Nothing
                    else
                        Just newAns
                )
                |> pureState

        ( Enter, nat, Just ans ) ->
            checkIfGoodAnswer config question nat (Just ans)

        _ ->
            RemainingTrials ( nat, answer )
                |> pureState


checkIfGoodAnswer :
    Config question
    -> question
    -> Nat
    -> Answer
    -> ( QuestionState, Cmd (Msg question) )
checkIfGoodAnswer config question nat answer =
    let
        badAnswer =
            case nat of
                Zero ->
                    Done 0 |> pureState

                Succ nat ->
                    ( RemainingTrials ( nat, Nothing )
                    , setTimeout config ( question, nat )
                    )
    in
        case answer of
            Just ans ->
                if ans == config.answerOf question then
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



-- Commands and subscriptions


setTimeout : Config question -> Id question -> Cmd (Msg question)
setTimeout { timeout } id =
    timeout
        * 1000
        |> toFloat
        |> Process.sleep
        |> Task.perform (always <| TimeOut id)


unlockCmd : Cmd (Msg question)
unlockCmd =
    Process.sleep 500
        |> Task.perform (always Unlock)


subscriptions : State question -> Sub (Msg question)
subscriptions { locked } =
    if locked then
        Sub.none
    else
        Keyboard.downs Key
