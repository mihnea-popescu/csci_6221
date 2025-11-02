module Game.Score exposing (..)

import Types.GameState exposing (Feedback(..), GameState)


{-| Calculate new score, streak, and feedback based on guess result
Max attempts is 3 - after that, show the answer and move on
-}
calculateResult : Bool -> Int -> GameState -> ( Int, Int, Feedback )
calculateResult isCorrect newAttempts gameState =
    if isCorrect then
        ( gameState.score + 1
        , gameState.streak + 1
        , Correct
        )

    else if newAttempts >= 3 then
        -- Max attempts reached - show answer and fail
        ( gameState.score
        , 0
        , Failed (getPokemonName gameState)
        )

    else
        ( gameState.score
        , 0
        , if newAttempts >= 2 then
            ShowHint (generateHint gameState)

          else
            Incorrect
        )


{-| Generate hint based on current Pokemon
-}
generateHint : GameState -> String
generateHint gameState =
    case gameState.currentPokemon of
        Just pokemon ->
            "Hint: First letter is " ++ String.toUpper (String.left 1 pokemon.name)

        Nothing ->
            "No hint available"


{-| Get the Pokemon name for displaying when failed
-}
getPokemonName : GameState -> String
getPokemonName gameState =
    case gameState.currentPokemon of
        Just pokemon ->
            pokemon.name

        Nothing ->
            "Unknown"


{-| Reset score and streak
-}
resetScore : GameState -> GameState
resetScore gameState =
    { gameState
        | score = 0
        , streak = 0
        , attempts = 0
        , feedback = NoFeedback
    }
