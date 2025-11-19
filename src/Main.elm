port module Main exposing (main)

import Api
import Backend
import Browser
import Game.State
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http
import Platform.Sub as Sub
import Process
import Randomizer
import Task
import Types.GameState as GameState exposing (GameState)
import Types.Leaderboard as Leaderboard exposing (LeaderboardState)
import Types.Msg exposing (Msg(..))
import UI.Feedback
import UI.GuessInput
import UI.PokemonDisplay
import UI.ScoreBoard
import UI.Leaderboard



-- PORTS (Elm <-> JavaScript Communication)


-- Mihnea's original ports for localStorage
port saveSeed : Int -> Cmd msg


port loadSeed : () -> Cmd msg


port onSeedLoaded : (Int -> msg) -> Sub msg


port savePlayerName : String -> Cmd msg


port loadPlayerName : () -> Cmd msg


port onPlayerNameLoaded : (Maybe String -> msg) -> Sub msg



-- Jaimin's new ports for sound effects


port playNewPokemonSound : () -> Cmd msg


port playCorrectGuessSound : () -> Cmd msg


port playFailureSound : () -> Cmd msg



-- FLAGS


type alias Flags =
    { userAgent : String
    , screenWidth : Int
    , screenHeight : Int
    , language : String
    , timezone : String
    }



-- MODEL


type alias Model =
    { randomizer : Randomizer.Model
    , gameState : GameState
    , loadedFromStorage : Bool
    , defaultSeed : Int
    , leaderboard : LeaderboardState
    }



-- INIT


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        fingerprintSeed =
            Randomizer.seedFromClientInfo
                { userAgent = flags.userAgent
                , screenWidth = flags.screenWidth
                , screenHeight = flags.screenHeight
                , language = flags.language
                , timezone = flags.timezone
                }
    in
    ( { randomizer = Randomizer.initWithSeed fingerprintSeed
      , gameState = GameState.init
      , loadedFromStorage = False
      , defaultSeed = fingerprintSeed
      , leaderboard = Leaderboard.initState
      }
    , Cmd.batch
        [ loadSeed ()
        , loadPlayerName ()
        , Backend.fetchLeaderboard LeaderboardLoaded
        ]
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SeedLoaded loadedSeed ->
            let
                actualSeed =
                    if loadedSeed == 0 then
                        model.defaultSeed

                    else
                        loadedSeed
            in
            if model.loadedFromStorage then
                ( model, Cmd.none )

            else
                ( { model
                    | randomizer = Randomizer.initWithSeed actualSeed
                    , loadedFromStorage = True
                  }
                , saveSeed actualSeed
                )

        SaveCurrentSeed ->
            ( model, saveSeed model.randomizer.baseSeed )

        ResetSeed ->
            let
                ( newRand, _, _ ) =
                    Randomizer.update Randomizer.ResetSeed model.randomizer
            in
            ( { model | randomizer = newRand }, saveSeed newRand.baseSeed )

        FetchRandom ->
            let
                ( newRand, maybeNum, nextCmd ) =
                    Randomizer.update Randomizer.Generate model.randomizer
            in
            case maybeNum of
                Nothing ->
                    ( { model | randomizer = newRand }
                    , Cmd.map RandomizerMsg nextCmd
                    )

                Just n ->
                    ( { model | randomizer = newRand }
                    , Cmd.batch
                        [ Api.getPokemonById (String.fromInt n) GotPokemon
                        , playNewPokemonSound ()
                        ]
                    )

        RandomizerMsg subMsg ->
            let
                ( newRand, maybeNum, nextCmd ) =
                    Randomizer.update subMsg model.randomizer
            in
            case maybeNum of
                Nothing ->
                    ( { model | randomizer = newRand }
                    , Cmd.map RandomizerMsg nextCmd
                    )

                Just n ->
                    ( { model | randomizer = newRand }
                    , Cmd.batch
                        [ Api.getPokemonById (String.fromInt n) GotPokemon
                        , playNewPokemonSound ()
                        ]
                    )

        GotPokemon result ->
            let
                ( newGameState, cmd ) =
                    Game.State.update msg model.gameState
            in
            ( { model | gameState = newGameState }, cmd )

        -- Jaimin's messages - delegate to Game.State
        UserGuessInput _ ->
            let
                ( newGameState, cmd ) =
                    Game.State.update msg model.gameState
            in
            ( { model | gameState = newGameState }, cmd )

        SubmitGuess ->
            let
                ( newGameState, cmd ) =
                    Game.State.update msg model.gameState

                -- Play appropriate sound based on feedback
                soundCmd =
                    case newGameState.feedback of
                        GameState.Correct ->
                            Cmd.batch
                                [ playCorrectGuessSound ()
                                , delayedFetch
                                ]

                        GameState.Failed _ ->
                            Cmd.batch
                                [ playFailureSound ()
                                , delayedFetch
                                ]

                        _ ->
                            Cmd.none
            in
            ( { model | gameState = newGameState }
            , Cmd.batch [ cmd, soundCmd ]
            )

        NextPokemon ->
            update FetchRandom model

        ResetGame ->
            let
                ( newGameState, cmd ) =
                    Game.State.update msg model.gameState
            in
            ( { model | gameState = newGameState }, cmd )

        FetchLeaderboard ->
            let
                leaderboard =
                    model.leaderboard

                updatedLeaderboard =
                    { leaderboard
                        | isLoading = True
                        , error = Nothing
                    }
            in
            ( { model | leaderboard = updatedLeaderboard }
            , Backend.fetchLeaderboard LeaderboardLoaded
            )

        LeaderboardLoaded (Ok entries) ->
            let
                leaderboard =
                    model.leaderboard

                updatedLeaderboard =
                    { leaderboard
                        | entries = entries
                        , isLoading = False
                        , error = Nothing
                    }
            in
            ( { model | leaderboard = updatedLeaderboard }
            , Cmd.none
            )

        LeaderboardLoaded (Err err) ->
            let
                leaderboard =
                    model.leaderboard

                updatedLeaderboard =
                    { leaderboard
                        | isLoading = False
                        , error = Just (leaderboardUnavailableMessage err)
                    }
            in
            ( { model | leaderboard = updatedLeaderboard }
            , Cmd.none
            )

        SaveScore ->
            if model.gameState.score <= 0 || model.leaderboard.isSaving then
                ( model, Cmd.none )

            else
                let
                    leaderboard =
                        model.leaderboard

                    updatedLeaderboard =
                        { leaderboard
                            | isSaving = True
                            , saveError = Nothing
                            , lastSavedName = Nothing
                        }
                in
                ( { model | leaderboard = updatedLeaderboard }
                , Backend.saveScore model.gameState.score leaderboard.playerName ScoreSaved
                )

        ScoreSaved (Ok response) ->
            let
                leaderboard =
                    model.leaderboard

                updatedLeaderboard =
                    { leaderboard
                        | isSaving = False
                        , lastSavedName = Just response.name
                        , playerName = Just response.name
                        , saveError = Nothing
                    }
            in
            ( { model | leaderboard = updatedLeaderboard }
            , Cmd.batch
                [ Backend.fetchLeaderboard LeaderboardLoaded
                , savePlayerName response.name
                ]
            )

        ScoreSaved (Err err) ->
            let
                leaderboard =
                    model.leaderboard

                updatedLeaderboard =
                    { leaderboard
                        | isSaving = False
                        , saveError = Just (leaderboardUnavailableMessage err)
                    }
            in
            ( { model | leaderboard = updatedLeaderboard }
            , Cmd.none
            )

        PlayerNameLoaded maybeName ->
            let
                leaderboard =
                    model.leaderboard

                updatedLeaderboard =
                    { leaderboard
                        | playerName = maybeName
                        , lastSavedName =
                            case maybeName of
                                Just name ->
                                    Just name

                                Nothing ->
                                    leaderboard.lastSavedName
                    }
            in
            ( { model | leaderboard = updatedLeaderboard }
            , Cmd.none
            )



-- HELPERS


{-| Auto-fetch next Pokemon after 5 seconds delay
-}
delayedFetch : Cmd Msg
delayedFetch =
    Process.sleep 5000
        |> Task.perform (always NextPokemon)


leaderboardUnavailableMessage : Http.Error -> String
leaderboardUnavailableMessage err =
    let
        details =
            Api.httpErrorToString err
    in
    "Leaderboard is not available right now. Please try again later. (" ++ details ++ ")"



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ style "font-family" "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif"
        , style "max-width" "1200px"
        , style "margin" "0 auto"
        , style "padding" "20px"
        , style "background-color" "white"
        , style "min-height" "100vh"
        ]
        [ -- Header
          div
            [ style "text-align" "center"
            , style "margin-bottom" "30px"
            ]
            [ div
                [ style "font-size" "42px"
                , style "font-weight" "bold"
                , style "color" "#2c3e50"
                , style "margin-bottom" "10px"
                ]
                [ text "🎮 Pokémon Guessing Game" ]
            , div
                [ style "color" "#7f8c8d"
                , style "font-size" "16px"
                ]
                [ text "Can you guess them all?" ]
            ]

        -- Main Game Container with Two Columns
        , div
            [ style "display" "grid"
            , style "grid-template-columns" "1fr 2fr"
            , style "gap" "30px"
            , style "margin-bottom" "30px"
            ]
            [ -- LEFT COLUMN: Scoreboard and Controls
              div
                [ style "display" "flex"
                , style "flex-direction" "column"
                , style "gap" "20px"
                ]
                [ -- Scoreboard
                  UI.ScoreBoard.view model.gameState
                , UI.Leaderboard.view model.gameState.score model.leaderboard

                -- Control Buttons
                , div
                    [ style "background-color" "#f8f9fa"
                    , style "padding" "20px"
                    , style "border-radius" "12px"
                    , style "box-shadow" "0 2px 8px rgba(0,0,0,0.1)"
                    ]
                    [ div
                        [ style "text-align" "center"
                        , style "margin-bottom" "15px"
                        , style "font-weight" "bold"
                        , style "color" "#2c3e50"
                        ]
                        [ text "Game Controls" ]
                    , div
                        [ style "display" "flex"
                        , style "flex-direction" "column"
                        , style "gap" "10px"
                        ]
                        [ button
                            [ onClick ResetGame
                            , style "padding" "12px 20px"
                            , style "font-size" "16px"
                            , style "background-color" "#e74c3c"
                            , style "color" "white"
                            , style "border" "none"
                            , style "border-radius" "6px"
                            , style "cursor" "pointer"
                            , style "font-weight" "bold"
                            , style "transition" "all 0.3s"
                            ]
                            [ text "🔄 Reset Game" ]
                        , button
                            [ onClick ResetSeed
                            , style "padding" "12px 20px"
                            , style "font-size" "16px"
                            , style "background-color" "#95a5a6"
                            , style "color" "white"
                            , style "border" "none"
                            , style "border-radius" "6px"
                            , style "cursor" "pointer"
                            , style "font-weight" "bold"
                            , style "transition" "all 0.3s"
                            ]
                            [ text "🔀 Reset Seed" ]
                        , div
                            [ style "margin-top" "10px"
                            , style "padding" "10px"
                            , style "background-color" "white"
                            , style "border-radius" "6px"
                            , style "text-align" "center"
                            , style "font-size" "14px"
                            , style "color" "#7f8c8d"
                            ]
                            [ text ("🌱 Seed: " ++ String.fromInt model.randomizer.baseSeed) ]
                        ]
                    ]
                ]

            -- RIGHT COLUMN: Game Area
            , div
                [ style "display" "flex"
                , style "flex-direction" "column"
                , style "gap" "20px"
                ]
                [ -- Start button (left-aligned)
                  div []
                    [ button
                        [ onClick FetchRandom
                        , style "padding" "15px 35px"
                        , style "font-size" "18px"
                        , style "cursor" "pointer"
                        , style "background-color" "#3498db"
                        , style "color" "white"
                        , style "border" "none"
                        , style "border-radius" "8px"
                        , style "font-weight" "bold"
                        , style "box-shadow" "0 4px 10px rgba(52,152,219,0.3)"
                        , style "transition" "all 0.3s"
                        ]
                        [ text "🎲 Start New Pokémon" ]
                    ]

                -- Pokemon Display
                , div
                    [ style "background-color" "#f8f9fa"
                    , style "padding" "30px"
                    , style "border-radius" "12px"
                    , style "box-shadow" "0 2px 8px rgba(0,0,0,0.1)"
                    ]
                    [ UI.PokemonDisplay.view model.gameState ]

                -- Guess Input
                , UI.GuessInput.view model.gameState

                -- Feedback
                , UI.Feedback.view model.gameState.feedback
                ]
            ]
        ]



-- MAIN


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ ->
            Sub.batch
                [ onSeedLoaded SeedLoaded
                , onPlayerNameLoaded PlayerNameLoaded
                ]
        }
