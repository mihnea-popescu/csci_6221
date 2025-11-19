module Types.Leaderboard exposing
    ( LeaderboardEntry
    , LeaderboardState
    , initState
    )


type alias LeaderboardEntry =
    { name : String
    , score : Int
    }


type alias LeaderboardState =
    { entries : List LeaderboardEntry
    , isLoading : Bool
    , isSaving : Bool
    , error : Maybe String
    , saveError : Maybe String
    , playerName : Maybe String
    , lastSavedName : Maybe String
    }


initState : LeaderboardState
initState =
    { entries = []
    , isLoading = False
    , isSaving = False
    , error = Nothing
    , saveError = Nothing
    , playerName = Nothing
    , lastSavedName = Nothing
    }
