module Types.GameState exposing (..)

import Api

type alias GameState =
    { currentPokemon : Maybe Api.Pokemon
    , userGuess : String
    , score : Int
    , streak : Int
    , attempts : Int
    , feedback : Feedback
    , setSeed : Maybe Int
    }

type Feedback
    = NoFeedback
    | Correct
    | Incorrect
    | ShowHint String
    | Failed String  -- NEW: For when max attempts reached

init : GameState
init =
    { currentPokemon = Nothing
    , userGuess = ""
    , score = 0
    , streak = 0
    , attempts = 0
    , feedback = NoFeedback
    , setSeed = Nothing
    }
