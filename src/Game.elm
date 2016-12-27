module Game exposing (..)

import Counter.Decreasing as Counter exposing (Counter)
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
            , nbTrials = 2
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


type QuestionState comparable
    = None
      -- nbTrialsLeft is to be understood: how many are left after the current trial
    | Active { question : comparable, answer : String, nbTrialsLeft : Counter }
    | Done { question : comparable, points : Int }


type alias Config comparable =
    { timeout : Int
    , nbTrials : Int
    , answerOf : comparable -> String
    , viewQuestion : comparable -> String
    }


type alias State comparable =
    { remainingQuestions : Set comparable
    , nbQuestionsLeft : Counter
    , pastQuestions : List { question : comparable, points : Int }
    , currentQuestion : QuestionState comparable
    , nextQuestion : Maybe comparable
    , locked : Bool
    , config : Config comparable
    }


type Msg comparable
    = Key KeyCode
    | Unlock
    | TimeOut Id
    | NextQuestion (Maybe comparable)


type alias Id =
    -- create a unique id from the nb of questions left and the nb of trials left
    ( Counter, Counter )


init :
    Config comparable
    -> Set comparable
    -> Int
    -> ( State comparable, Cmd (Msg comparable) )
init config questions nbQuestions =
    ( { remainingQuestions = questions
      , nbQuestionsLeft = Counter.init nbQuestions
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
            ++ (Counter.print state.nbQuestionsLeft)
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
            []

        Active { question, answer, nbTrialsLeft } ->
            [ Html.div []
                [ question |> config.viewQuestion |> Html.text
                , (if String.isEmpty answer then
                    "?"
                   else
                    answer
                  )
                    |> Html.text
                ]
            , Html.div [] [ nbTrialsLeft |> viewTrialsLeft |> Html.text ]
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


viewTrialsLeft : Counter -> String
viewTrialsLeft =
    Counter.printWith
        (\nbTrialsLeft ->
            if nbTrialsLeft == 0 then
                "Dernier essai."
            else
                (nbTrialsLeft + 1 |> toString) ++ " essais restants."
        )


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
                ( state.currentQuestion, state.nextQuestion, keyInterp key )
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
                    { state
                        | pastQuestions = pastQuestion :: state.pastQuestions
                        , currentQuestion = None
                    }
                        |> updateNextQuestion newQuestion

                _ ->
                    pureState state

        Unlock ->
            { state | locked = False } |> pureState

        TimeOut id ->
            case state.currentQuestion of
                Active questionState ->
                    if checkId id state then
                        checkAnswer state questionState True
                    else
                        -- false alarm
                        pureState state

                _ ->
                    pureState state

        NextQuestion (Just question) ->
            case state.currentQuestion of
                None ->
                    state |> updateNextQuestion question

                Active _ ->
                    -- normally, we shouldn't be in that branch
                    pureState state

                Done _ ->
                    { state | nextQuestion = Just question } |> pureState

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
    -> { question : comparable, answer : String, nbTrialsLeft : Counter }
    -> Bool
    -> ( State comparable, Cmd (Msg comparable) )
checkAnswer state { question, answer, nbTrialsLeft } timeout =
    let
        unlockCmds =
            if timeout then
                -- we lock for a little while in case the user
                -- presses a key just after the timeout
                [ unlockCmd ]
            else
                []

        nextQuestionCmds =
            [ chooseNextQuestion state.remainingQuestions ]
    in
        if String.isEmpty answer && not timeout then
            pureState state
        else if answer == state.config.answerOf question then
            { state
                | currentQuestion =
                    Done
                        { question = question
                        , points = computePoints nbTrialsLeft
                        }
                , locked = timeout
            }
                ! (unlockCmds ++ nextQuestionCmds)
        else
            case Counter.decr nbTrialsLeft of
                Nothing ->
                    { state
                        | currentQuestion = Done { question = question, points = 0 }
                        , locked = timeout
                    }
                        ! (unlockCmds ++ nextQuestionCmds)

                Just nbTrialsLeft ->
                    let
                        questionState =
                            { question = question
                            , answer = ""
                            , nbTrialsLeft = nbTrialsLeft
                            }
                    in
                        { state
                            | currentQuestion = Active questionState
                            , locked = timeout
                        }
                            ! (setTimeout state.config.timeout
                                ( state.nbQuestionsLeft, nbTrialsLeft )
                                :: unlockCmds
                              )


updateNextQuestion :
    comparable
    -> State comparable
    -> ( State comparable, Cmd (Msg comparable) )
updateNextQuestion newQuestion state =
    case state.nbQuestionsLeft |> Counter.decr of
        Nothing ->
            pureState state

        Just nbQuestionsLeft ->
            let
                nbTrialsLeft =
                    state.config.nbTrials - 1 |> Counter.init

                questionState =
                    { question = newQuestion
                    , answer = ""
                    , nbTrialsLeft = nbTrialsLeft
                    }
            in
                ( { state
                    | currentQuestion = Active questionState
                    , nextQuestion = Nothing
                    , remainingQuestions =
                        state.remainingQuestions |> Set.remove newQuestion
                    , nbQuestionsLeft = nbQuestionsLeft
                  }
                , setTimeout state.config.timeout ( nbQuestionsLeft, nbTrialsLeft )
                )


checkId : Id -> State comparable -> Bool
checkId id state =
    case state.currentQuestion of
        Active { nbTrialsLeft } ->
            id == ( state.nbQuestionsLeft, nbTrialsLeft )

        _ ->
            False


computePoints : Counter -> number
computePoints counter =
    case Counter.decr counter of
        Nothing ->
            1

        Just counter ->
            2 * (computePoints counter) + 1



-- Commands and subscriptions


setTimeout : number -> Id -> Cmd (Msg comparable)
setTimeout timeout id =
    timeout * 1000 |> Process.sleep |> Task.perform (always <| TimeOut id)


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
