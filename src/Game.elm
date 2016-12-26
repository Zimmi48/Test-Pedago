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
            Set.fromList [ ( 9, 3 ), ( 2, 3 ), ( 6, 7 ) ]

        config =
            { timeout = 5
            , answerOf = \( x, y ) -> toString (x * y)
            , viewQuestion =
                \( x, y ) -> toString x ++ " × " ++ toString y ++ " = "
            }
    in
        Html.program
            { init = init config questions
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
    | Active { question : comparable, answer : Maybe String, trialsLeft : Nat }
      -- trialsLeft is to be understood: how many are left after the current trial
    | Done { question : comparable, points : Int }


type alias Config comparable =
    { timeout : Int
    , answerOf : comparable -> String
    , viewQuestion : comparable -> String
    }


type alias State comparable =
    { remainingQuestions : Set comparable
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
    ( comparable, Nat )



-- Create a unique id from the question and the remaining trials
-- One must assume that there won't be identical questions in one set
-- TODO: make this impossible


init : Config comparable -> Set comparable -> ( State comparable, Cmd (Msg comparable) )
init config questions =
    ( { remainingQuestions = questions
      , pastQuestions = []
      , currentQuestion = None
      , nextQuestion = Nothing
      , locked = False
      , config = config
      }
    , chooseNextQuestion questions
    )


initQuestionState : comparable -> QuestionState comparable
initQuestionState question =
    Active { question = question, answer = Nothing, initRemainings = Succ Zero }


view : State comparable -> Html msg
view state =
    Html.div []
        [ state.pastQuestions
            |> List.map (viewPastQuestion state.config)
            |> Html.ul []
        , viewCurrent state.config state.currentQuestion
        , "Questions restantes: "
            ++ (state.remaining |> Set.size |> toString)
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
                , answer |> Maybe.withDefault "?" |> Html.text
                ]
            , Html.div [ trialsLeft |> viewTrialsLeft |> Html.text ]
            ]

        Done { question, points } ->
            [ Html.div []
                [ question |> config.viewQuestion |> Html.text
                , question |> config.answerOf |> Html.text
                ]
            , Html.div [ points |> viewPoints |> Html.text ]
            ]
    )
        |> Html.div []


viewTrialsLeft trialsLeft =
    case trialsLeft of
        Zero ->
            "Dernier essai."

        _ ->
            (trialsLeft |> toInt |> (+) 1 |> toString) ++ " essais restants."


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
                            { answer = questionState |> addToAnswer (toString d) }
                                |> Active
                    }
                        |> pureState

                ( Active questionState, _, Backspace ) ->
                    { state
                        | currentQuestion =
                            { answer = questionState.answer |> removeFromAnswer }
                                |> Active
                    }
                        |> pureState

                ( Active questionState, _, Enter ) ->
                    checkAnswer state questionState False

                ( Done pastQuestion, Just newQuestion, Enter ) ->
                    ( { state
                        | pastQuestions = pastQuestion :: state.pastQuestions
                        , currentQuestion = initQuestionState newQuestion
                        , nextQuestion = Nothing
                      }
                    , setTimeout state.config newQuestion
                    )

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


addToAnswer add answer =
    case answer of
        Nothing ->
            Just add

        Just "0" ->
            Just add

        Just ans ->
            Just <| ans ++ add


removeFromAnswer answer =
    Maybe.andThen
        (\ans ->
            let
                newAns =
                    String.dropRight 1 ans
            in
                if String.isEmpty newAns then
                    Nothing
                else
                    Just newAns
        )
        answer


checkAnswer :
    State comparable
    -> { question : comparable, answer : Maybe String, trialsLeft : Nat }
    -> Bool
    -> ( State comparable, Cmd (Msg comparable) )
checkAnswer state { question, answer, trialsLeft } timeout =
    let
        cmds =
            if timeout then
                [ unlockCmd ]
            else
                []

        badAnswer =
            case trialsLeft of
                Zero ->
                    -- we lock for a little while in case the user
                    -- presses a key just after the timeout
                    { state
                        | currentQuestion = Done 0
                        , locked = timeout
                    }
                        ! ([ chooseNextQuestion state.remainingQuestions ] ++ cmds)

                Succ nat ->
                    { state
                        | currentQuestion =
                            { question = question
                            , answer = Nothing
                            , trialsLeft = nat
                            }
                        , locked = timeout
                    }
                        ! ([ setTimeout state.config ( question, nat ) ] ++ cmds)
    in
        case state.answer of
            Just ans ->
                if ans == state.config.answerOf question then
                    { state
                        | question =
                            Done
                                { question = question
                                , points = computePoints state.trialsLeft
                                }
                        , locked = timeout
                    }
                        ! cmds
                else
                    badAnswer

            Nothing ->
                if timeout then
                    badAnswer
                else
                    question |> pureState


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


setTimeout : Config comparable -> QuestionState -> Cmd (Msg comparable)
setTimeout { timeout } { question, trialsLeft } =
    timeout
        * 1000
        |> toFloat
        |> Process.sleep
        |> Task.perform (( question, trialsLeft ) |> TimeOut |> always)


unlockCmd : Cmd (Msg comparable)
unlockCmd =
    Process.sleep 500
        |> Task.perform (always Unlock)


chooseNextQuestion questions =
    Random.Set.sample questions |> Random.generate NextQuestion


subscriptions : State comparable -> Sub (Msg comparable)
subscriptions { locked } =
    if locked then
        Sub.none
    else
        Keyboard.downs Key
