module Backend exposing
    ( LeaderboardEntry
    , SaveResponse
    , fetchLeaderboard
    , saveScore
    )

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Types.Leaderboard as Leaderboard


type alias LeaderboardEntry =
    Leaderboard.LeaderboardEntry


type alias SaveResponse =
    { success : Bool
    , name : String
    }


baseUrl : String
baseUrl =
    "http://localhost:9000"


fetchLeaderboard : (Result Http.Error (List LeaderboardEntry) -> msg) -> Cmd msg
fetchLeaderboard toMsg =
    Http.get
        { url = baseUrl ++ "/leaderboard"
        , expect = Http.expectJson toMsg leaderboardDecoder
        }


saveScore : Int -> Maybe String -> (Result Http.Error SaveResponse -> msg) -> Cmd msg
saveScore score maybeName toMsg =
    let
        payloadFields =
            case maybeName of
                Just name ->
                    [ ( "score", Encode.int score ), ( "name", Encode.string name ) ]

                Nothing ->
                    [ ( "score", Encode.int score ) ]
    in
    Http.post
        { url = baseUrl ++ "/save"
        , body =
            Http.jsonBody <|
                Encode.object payloadFields
        , expect = Http.expectJson toMsg saveResponseDecoder
        }


leaderboardDecoder : Decoder (List LeaderboardEntry)
leaderboardDecoder =
    Decode.list leaderboardEntryDecoder


leaderboardEntryDecoder : Decoder LeaderboardEntry
leaderboardEntryDecoder =
    Decode.map2
        (\name score -> { name = name, score = score })
        (Decode.field "name" Decode.string)
        (Decode.field "score" Decode.int)


saveResponseDecoder : Decoder SaveResponse
saveResponseDecoder =
    Decode.map2
        (\success name -> { success = success, name = name })
        (Decode.field "success" Decode.bool)
        (Decode.field "name" Decode.string)
