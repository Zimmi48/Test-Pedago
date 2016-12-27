module Game exposing (..)

import Html exposing (Html)
import Keyboard exposing (KeyCode)
import Lib exposing (..)
import Process
import Random
import Random.Set
import Set exposing (Set)
import Task


main : Program Never (State ( Int, Int )) (Msg ( Int, Int ))
main =
    let
        questions =
            List.range 2 9
                |> (\l -> List.map (\x -> List.map ((,) x) l) l)
                |> List.concat
                |> Set.fromList

        config =
            { timeout = 5
            , answerOf = \( x, y ) -> toString (x * y)
            , viewQuestion =
                \( x, y ) -> toString x ++ " × " ++ toString y ++ " = "
            }
    in
        Html.program
            { init = init config questions 10
            , view = view
            , update = update
            , subscriptions = subscriptions
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


type QuestionState comparable
    = None
      -- trialsLeft is to be understood: how many are left after the current trial
    | Active { question : comparable, answer : String, trialsLeft : Nat }
    | Done { question : comparable, points : Int }


type alias Config comparable =
    { timeout : Int
    , answerOf : comparable -> String
    , viewQuestion : comparable -> String
    }


type alias State comparable =
    { remainingQuestions : Set comparable
    , nbRemainingQuestions : Int
    , pastQuestions : List { question : comparable, points : Int }
    , currentQuestion : QuestionState comparable
    , nextQuestion : Maybe comparable
    , locked : Bool
    , config : Config comparable
    }


type Msg comparable
    = Key KeyCode
    | Unlock
    | TimeOut (Id comparable)
    | NextQuestion (Maybe comparable)


type alias Id comparable =
    -- Create a unique id from the question and the remaining trials
    ( comparable, Nat )


init :
    Config comparable
    -> Set comparable
    -> Int
    -> ( State comparable, Cmd (Msg comparable) )
init config questions nbQuestions =
    ( { remainingQuestions = questions
      , nbRemainingQuestions = nbQuestions
      , pastQuestions = []
      , currentQuestion = None
      , nextQuestion = Nothing
      , locked = False
      , config = config
      }
    , chooseNextQuestion questions
    )


view : State comparable -> Html msg
view state =
    Html.div []
        [ state.pastQuestions
            |> List.reverse
            |> List.map (viewPastQuestion state.config)
            |> Html.ul []
        , viewCurrent state.config state.currentQuestion
        , "Questions restantes: "
            ++ (state.nbRemainingQuestions |> toString)
            |> Html.text
        ]


viewPastQuestion :
    Config comparable
    -> { question : comparable, points : Int }
    -> Html msg
viewPastQuestion config { question, points } =
    Html.li []
        [ config.viewQuestion question
            ++ config.answerOf question
            ++ " : "
            ++ viewPoints points
            |> Html.text
        ]


viewCurrent : Config comparable -> QuestionState comparable -> Html msg
viewCurrent config state =
    (case state of
        None ->
            [ Html.text "Question en cours de préparation." ]

        Active { question, answer, trialsLeft } ->
            [ Html.div []
                [ question |> config.viewQuestion |> Html.text
                , (if String.isEmpty answer then
                    "?"
                   else
                    answer
                  )
                    |> Html.text
                ]
            , Html.div [] [ trialsLeft |> viewTrialsLeft |> Html.text ]
            ]

        Done { question, points } ->
            [ Html.div []
                [ question |> config.viewQuestion |> Html.text
                , question |> config.answerOf |> Html.text
                ]
            , Html.div [] [ points |> viewPoints |> Html.text ]
            ]
    )
        |> Html.div []


viewTrialsLeft : Nat -> String
viewTrialsLeft trialsLeft =
    case trialsLeft of
        Zero ->
            "Dernier essai."

        _ ->
            (trialsLeft |> toInt |> (+) 1 |> toString) ++ " essais restants."


viewPoints : Int -> String
viewPoints points =
    if points >= 2 then
        toString points ++ " points"
    else
        toString points ++ " point"


update :
    Msg comparable
    -> State comparable
    -> ( State comparable, Cmd (Msg comparable) )
update msg state =
    case msg of
        Key key ->
            case
                ( state.currentQuestion
                , state.nextQuestion
                , keyInterp key
                )
            of
                ( Active questionState, _, Digit d ) ->
                    { state
                        | currentQuestion =
                            { questionState
                                | answer =
                                    questionState.answer |> addToAnswer (toString d)
                            }
                                |> Active
                    }
                        |> pureState

                ( Active questionState, _, Backspace ) ->
                    { state
                        | currentQuestion =
                            { questionState
                                | answer = questionState.answer |> removeFromAnswer
                            }
                                |> Active
                    }
                        |> pureState

                ( Active questionState, _, Enter ) ->
                    checkAnswer state questionState False

                ( Done pastQuestion, Just newQuestion, Enter ) ->
                    { state | pastQuestions = pastQuestion :: state.pastQuestions }
                        |> updateNextQuestion newQuestion

                _ ->
                    pureState state

        Unlock ->
            { state | locked = False } |> pureState

        TimeOut id ->
            case state.currentQuestion of
                Active questionState ->
                    if checkId id questionState then
                        checkAnswer state questionState True
                    else
                        -- false alarm
                        pureState state

                _ ->
                    pureState state

        NextQuestion (Just question) ->
            case state.currentQuestion of
                None ->
                    { state
                        | remainingQuestions =
                            Set.remove question state.remainingQuestions
                        , nbRemainingQuestions = state.nbRemainingQuestions - 1
                    }
                        |> updateNextQuestion question

                Active _ ->
                    -- normally, we shouldn't be in that branch
                    pureState state

                Done _ ->
                    { state
                        | nextQuestion = Just question
                        , remainingQuestions =
                            Set.remove question state.remainingQuestions
                        , nbRemainingQuestions = state.nbRemainingQuestions - 1
                    }
                        |> pureState

        NextQuestion Nothing ->
            -- game finished
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


addToAnswer : String -> String -> String
addToAnswer add answer =
    if answer == "0" then
        add
    else
        answer ++ add


removeFromAnswer : String -> String
removeFromAnswer answer =
    String.dropRight 1 answer


checkAnswer :
    State comparable
    -> { question : comparable, answer : String, trialsLeft : Nat }
    -> Bool
    -> ( State comparable, Cmd (Msg comparable) )
checkAnswer state { question, answer, trialsLeft } timeout =
    let
        unlockCmds =
            if timeout then
                -- we lock for a little while in case the user
                -- presses a key just after the timeout
                [ unlockCmd ]
            else
                []

        nextQuestionCmds =
            if state.nbRemainingQuestions >= 1 then
                [ chooseNextQuestion state.remainingQuestions ]
            else
                []
    in
        if String.isEmpty answer && not timeout then
            pureState state
        else if answer == state.config.answerOf question then
            { state
                | currentQuestion =
                    Done
                        { question = question
                        , points = computePoints trialsLeft
                        }
                , locked = timeout
            }
                ! (unlockCmds ++ nextQuestionCmds)
        else
            case trialsLeft of
                Zero ->
                    { state
                        | currentQuestion = Done { question = question, points = 0 }
                        , locked = timeout
                    }
                        ! (unlockCmds ++ nextQuestionCmds)

                Succ nat ->
                    let
                        questionState =
                            { question = question
                            , answer = ""
                            , trialsLeft = nat
                            }
                    in
                        { state
                            | currentQuestion = Active questionState
                            , locked = timeout
                        }
                            ! ([ setTimeout state.config questionState ]
                                ++ unlockCmds
                              )


updateNextQuestion :
    comparable
    -> State comparable
    -> ( State comparable, Cmd (Msg comparable) )
updateNextQuestion newQuestion state =
    let
        questionState =
            { question = newQuestion
            , answer = ""
            , trialsLeft = Succ Zero
            }
    in
        ( { state
            | currentQuestion = Active questionState
            , nextQuestion = Nothing
          }
        , setTimeout state.config questionState
        )


checkId : ( a, b ) -> { c | question : a, trialsLeft : b } -> Bool
checkId id { question, trialsLeft } =
    id == ( question, trialsLeft )


computePoints : Nat -> number
computePoints nat =
    case nat of
        Zero ->
            1

        Succ nat ->
            2 * (computePoints nat) + 1



-- Commands and subscriptions


setTimeout :
    Config comparable
    -> { a | question : comparable, trialsLeft : Nat }
    -> Cmd (Msg comparable)
setTimeout { timeout } { question, trialsLeft } =
    timeout
        * 1000
        |> toFloat
        |> Process.sleep
        |> Task.perform (( question, trialsLeft ) |> TimeOut |> always)


unlockCmd : Cmd (Msg comparable)
unlockCmd =
    Process.sleep 500 |> Task.perform (always Unlock)


chooseNextQuestion : Set comparable -> Cmd (Msg comparable)
chooseNextQuestion questions =
    Random.Set.sample questions |> Random.generate NextQuestion


subscriptions : State comparable -> Sub (Msg comparable)
subscriptions { locked } =
    if locked then
        Sub.none
    else
        Keyboard.downs Key
