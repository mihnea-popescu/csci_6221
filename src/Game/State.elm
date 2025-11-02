module Game.State exposing (..)

import Api
import Game.Score as Score
import Types.GameState as GameState exposing (GameState)
import Types.Msg exposing (Msg(..))


{-| Update game state based on messages
This is Jaimin's core responsibility
-}
update : Msg -> GameState -> ( GameState, Cmd Msg )
update msg gameState =
    case msg of
        GotPokemon (Ok pokemon) ->
            handleNewPokemon pokemon gameState

        UserGuessInput guess ->
            ( { gameState | userGuess = guess }, Cmd.none )

        SubmitGuess ->
            handleGuessSubmission gameState

        NextPokemon ->
            -- This will be handled by Main.elm to fetch new Pokemon
            ( gameState, Cmd.none )

        ResetGame ->
            ( GameState.init, Cmd.none )

        _ ->
            ( gameState, Cmd.none )


{-| Handle new Pokemon received from API
-}
handleNewPokemon : Api.Pokemon -> GameState -> ( GameState, Cmd Msg )
handleNewPokemon pokemon gameState =
    ( { gameState
        | currentPokemon = Just pokemon
        , userGuess = ""
        , attempts = 0
        , feedback = GameState.NoFeedback
      }
    , Cmd.none
    )


{-| Handle guess submission and calculate result
-}
handleGuessSubmission : GameState -> ( GameState, Cmd Msg )
handleGuessSubmission gameState =
    case gameState.currentPokemon of
        Nothing ->
            ( gameState, Cmd.none )

        Just pokemon ->
            let
                isCorrect =
                    checkGuess gameState.userGuess pokemon.name

                newAttempts =
                    gameState.attempts + 1

                ( newScore, newStreak, feedback ) =
                    Score.calculateResult isCorrect newAttempts gameState
            in
            ( { gameState
                | score = newScore
                , streak = newStreak
                , attempts = newAttempts
                , feedback = feedback
              }
            , Cmd.none
            )


{-| Check if guess matches Pokemon name (case-insensitive)
-}
checkGuess : String -> String -> Bool
checkGuess guess pokemonName =
    String.toLower (String.trim guess) == String.toLower pokemonName