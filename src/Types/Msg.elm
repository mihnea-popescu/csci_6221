module Types.Msg exposing (..)

import Api
import Backend
import Http
import Randomizer


type Msg
    = RandomizerMsg Randomizer.Msg
    | FetchRandom
    | FetchLeaderboard
    | GotPokemon (Result Http.Error Api.Pokemon)
    | LeaderboardLoaded (Result Http.Error (List Backend.LeaderboardEntry))
    | SaveScore
    | ScoreSaved (Result Http.Error Backend.SaveResponse)
    | PlayerNameLoaded (Maybe String)
    | SeedLoaded Int
    | SaveCurrentSeed
    | ResetSeed
    | UserGuessInput String
    | SubmitGuess
    | NextPokemon
    | ResetGame
    | SetSeed
    | SeedInputChanged String
