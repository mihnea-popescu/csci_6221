module Types.Msg exposing (..)

import Api
import Http
import Randomizer

type Msg
    = RandomizerMsg Randomizer.Msg
    | FetchRandom
    | GotPokemon (Result Http.Error Api.Pokemon)
    | SeedLoaded Int
    | SaveCurrentSeed
    | ResetSeed
    | UserGuessInput String
    | SubmitGuess
    | NextPokemon
    | ResetGame
    