module Game exposing (..)

import Char
import Counter.Decreasing as Counter exposing (Counter)
import Html exposing (Html)
import Keyboard exposing (KeyCode)
import Process
import Random
import Random.Set
import Return exposing (Return)
import Set exposing (Set)
import Task


main : Program Never (State ( Int, Int )) (Msg ( Int, Int ))
main =
    let
        questions =
            List.range 3 9
                |> (\l -> List.map (\x -> List.map ((,) x) l) l)
                |> List.concat
                |> Set.fromList

        config =
            { timeout = 5
            , nbTrials = 2
            , answerOf = \( x, y ) -> toString (x * y)
            , viewQuestion =
                \( x, y ) -> toString x ++ " × " ++ toString y ++ " = "
            , allowedKey = \key -> key >= 48 && key <= 57
            , addToAnswer =
                \add answer ->
                    let
                        app =
                            add |> Char.fromCode |> String.fromChar
                    in
                        if answer == "0" then
                            app
                        else
                            answer ++ app
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
    { timeout : Float
    , nbTrials : Int
    , answerOf : comparable -> String
    , viewQuestion : comparable -> String
    , allowedKey : KeyCode -> Bool
    , addToAnswer : KeyCode -> String -> String
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
    = EnterKey
    | EditKey (String -> String)
    | Unlock
    | TimeOut Id
    | NextQuestion (Maybe comparable)
    | NoOp


type alias Id =
    -- create a unique id from the nb of questions left and the nb of trials left
    ( Counter, Counter )


init :
    Config comparable
    -> Set comparable
    -> Int
    -> Return (Msg comparable) (State comparable)
init config questions nbQuestions =
    { remainingQuestions = questions
    , nbQuestionsLeft = Counter.init nbQuestions
    , pastQuestions = []
    , currentQuestion = None
    , nextQuestion = Nothing
    , locked = False
    , config = config
    }
        |> chooseNextQuestion


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
            [ "Appuyer sur Entrée pour commencer." |> Html.text ]

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
            , Html.div [] [ "Appuyer sur Entrée pour continuer." |> Html.text ]
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
    -> Return (Msg comparable) (State comparable)
update msg state =
    case msg of
        EditKey edit ->
            (case state.currentQuestion of
                Active questionState ->
                    Active { questionState | answer = edit questionState.answer }

                questionState ->
                    questionState
            )
                |> (\question -> { state | currentQuestion = question })
                |> Return.singleton

        EnterKey ->
            case state.currentQuestion of
                Active questionState ->
                    checkAnswer state questionState False

                Done pastQuestion ->
                    { state
                        | pastQuestions = pastQuestion :: state.pastQuestions
                        , currentQuestion = None
                    }
                        |> updateNextQuestion

                None ->
                    updateNextQuestion state

        Unlock ->
            Return.singleton { state | locked = False }

        TimeOut id ->
            case state.currentQuestion of
                Active questionState ->
                    if checkId id state then
                        checkAnswer state questionState True
                    else
                        -- false alarm
                        Return.singleton state

                _ ->
                    Return.singleton state

        NextQuestion (Just question) ->
            Return.singleton { state | nextQuestion = Just question }

        NextQuestion Nothing ->
            -- TODO: game finished
            Return.singleton state

        NoOp ->
            Return.singleton state


type Key
    = Char String
    | Backspace


keyInterp : Config comparable -> KeyCode -> Msg comparable
keyInterp config key =
    if config.allowedKey key then
        key |> config.addToAnswer |> EditKey
    else if key == 13 then
        EnterKey
    else if key == 8 then
        String.dropRight 1 |> EditKey
    else
        NoOp


checkAnswer :
    State comparable
    -> { question : comparable, answer : String, nbTrialsLeft : Counter }
    -> Bool
    -> Return (Msg comparable) (State comparable)
checkAnswer state { question, answer, nbTrialsLeft } timeout =
    if String.isEmpty answer && not timeout then
        -- we do not take Enter into account if the answer is empty
        Return.singleton state
    else
        (if answer == state.config.answerOf question then
            -- correct!
            Done { question = question, points = computePoints nbTrialsLeft }
         else
            -- wrong answer: do we have some trials left?
            case Counter.decr nbTrialsLeft of
                Nothing ->
                    Done { question = question, points = 0 }

                Just nbTrialsLeft ->
                    Active
                        { question = question
                        , answer = ""
                        , nbTrialsLeft = nbTrialsLeft
                        }
        )
            |> (\currentQuestion -> { state | currentQuestion = currentQuestion })
            |> setTimeout
            |> (if timeout then
                    -- we lock for a little while in case the user
                    -- presses a key just after the timeout
                    Return.andThen setLock
                else
                    identity
               )


updateNextQuestion : State comparable -> Return (Msg comparable) (State comparable)
updateNextQuestion state =
    case
        ( state.currentQuestion
        , state.nextQuestion
        , Counter.decr state.nbQuestionsLeft
        )
    of
        ( None, Just newQuestion, Just nbQuestionsLeft ) ->
            let
                nbTrialsLeft =
                    state.config.nbTrials - 1 |> Counter.init
            in
                { state
                    | currentQuestion =
                        Active
                            { question = newQuestion
                            , answer = ""
                            , nbTrialsLeft = nbTrialsLeft
                            }
                    , nextQuestion = Nothing
                    , remainingQuestions =
                        Set.remove newQuestion state.remainingQuestions
                    , nbQuestionsLeft = nbQuestionsLeft
                }
                    |> setTimeout
                    |> Return.andThen chooseNextQuestion

        _ ->
            Return.singleton state


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


chooseNextQuestion : State comparable -> Return (Msg comparable) (State comparable)
chooseNextQuestion state =
    case state.nextQuestion of
        Just _ ->
            Return.singleton state

        Nothing ->
            Random.Set.sample state.remainingQuestions
                |> Random.generate NextQuestion
                |> Return.return state


setTimeout : State comparable -> Return (Msg comparable) (State comparable)
setTimeout state =
    case state.currentQuestion of
        Active { nbTrialsLeft } ->
            Task.perform
                (( state.nbQuestionsLeft, nbTrialsLeft ) |> TimeOut |> always)
                (state.config.timeout * 1000 |> Process.sleep)
                |> Return.return state

        _ ->
            Return.singleton state


setLock : State comparable -> Return (Msg comparable) (State comparable)
setLock state =
    Process.sleep 500
        |> Task.perform (always Unlock)
        |> Return.return { state | locked = True }


subscriptions : State comparable -> Sub (Msg comparable)
subscriptions state =
    if state.locked then
        Sub.none
    else
        Keyboard.downs (keyInterp state.config)
