module UI.Leaderboard exposing (view)

import Html exposing (Html, button, div, span, text)
import Html.Attributes exposing (disabled, style)
import Html.Events exposing (onClick)
import Types.Leaderboard exposing (LeaderboardEntry, LeaderboardState)
import Types.Msg exposing (Msg(..))


view : Int -> LeaderboardState -> Html Msg
view currentScore leaderboard =
    let
        saveDisabled =
            currentScore <= 0 || leaderboard.isSaving

        statusMessage =
            if leaderboard.isLoading then
                Just "Fetching latest scores..."

            else
                Nothing
    in
    div
        [ style "background-color" "white"
        , style "padding" "20px"
        , style "border-radius" "12px"
        , style "box-shadow" "0 2px 8px rgba(0,0,0,0.1)"
        , style "display" "flex"
        , style "flex-direction" "column"
        , style "gap" "12px"
        ]
        [ headerRow
        , case statusMessage of
            Just msg ->
                statusText "#3498db" msg

            Nothing ->
                text ""
        , case leaderboard.error of
            Just err ->
                statusText "#e74c3c" err

            Nothing ->
                text ""
        , leaderboard.lastSavedName
            |> Maybe.map (\name -> statusText "#16a085" ("Saved as " ++ name ++ "!"))
            |> Maybe.withDefault (text "")
        , leaderboard.saveError
            |> Maybe.map (\err -> statusText "#e74c3c" err)
            |> Maybe.withDefault (text "")
        , div [] (viewEntries leaderboard.entries)
        , div
            [ style "display" "flex"
            , style "flex-direction" "column"
            , style "gap" "8px"
            , style "margin-top" "8px"
            ]
            [ span [ style "font-size" "14px", style "color" "#7f8c8d" ]
                [ text ("Current score: " ++ String.fromInt currentScore) ]
            , button
                [ onClick SaveScore
                , disabled saveDisabled
                , style "padding" "12px"
                , style "background-color" (if saveDisabled then "#bdc3c7" else "#27ae60")
                , style "color" "white"
                , style "border" "none"
                , style "border-radius" "6px"
                , style "cursor" (if saveDisabled then "not-allowed" else "pointer")
                , style "font-weight" "bold"
                ]
                [ text
                    (if leaderboard.isSaving then
                        "Saving..."

                     else
                        "💾 Save Score to Leaderboard"
                    )
                ]
            ]
        ]


headerRow : Html Msg
headerRow =
    div
        [ style "display" "flex"
        , style "justify-content" "space-between"
        , style "align-items" "center"
        ]
        [ span
            [ style "font-weight" "bold"
            , style "color" "#2c3e50"
            , style "font-size" "18px"
            ]
            [ text "🏅 Leaderboard" ]
        , button
            [ onClick FetchLeaderboard
            , style "background-color" "#3498db"
            , style "color" "white"
            , style "border" "none"
            , style "border-radius" "6px"
            , style "padding" "8px 12px"
            , style "cursor" "pointer"
            ]
            [ text "Refresh" ]
        ]


statusText : String -> String -> Html msg
statusText color msg =
    div
        [ style "font-size" "13px"
        , style "color" color
        ]
        [ text msg ]


viewEntries : List LeaderboardEntry -> List (Html Msg)
viewEntries entries =
    if List.isEmpty entries then
        [ div
            [ style "text-align" "center"
            , style "color" "#7f8c8d"
            , style "padding" "20px 0"
            ]
            [ text "No high scores yet. Be the first!" ]
        ]

    else
        List.indexedMap viewEntry entries


viewEntry : Int -> LeaderboardEntry -> Html Msg
viewEntry index entry =
    div
        [ style "display" "flex"
        , style "justify-content" "space-between"
        , style "padding" "8px 0"
        , style "border-bottom" "1px solid #ecf0f1"
        ]
        [ span [ style "font-weight" "500", style "color" "#2c3e50" ]
            [ text
                (String.fromInt (index + 1) ++ ". " ++ entry.name)
            ]
        , span [ style "font-weight" "bold", style "color" "#8e44ad" ]
            [ text (String.fromInt entry.score) ]
        ]
