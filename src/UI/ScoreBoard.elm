module UI.ScoreBoard exposing (view)

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (style)
import Types.GameState exposing (GameState)
import Types.Msg exposing (Msg)


view : GameState -> Html Msg
view gameState =
    div
        [ style "background" "#181823"
        , style "color" "white"
        , style "padding" "25px"
        , style "border-radius" "12px"
        , style "margin-bottom" "25px"
        , style "display" "flex"
        , style "justify-content" "space-around"
        , style "align-items" "center"
        , style "box-shadow" "0 4px 15px rgba(0,0,0,0.2)"
        ]
        [ viewStat "🏆 Score" gameState.score
        , viewStat "🔥 Streak" gameState.streak
        , viewStat "🎯 Attempts" gameState.attempts
        ]


viewStat : String -> Int -> Html Msg
viewStat label value =
    let
        emoji =
            String.left 2 label -- extract emoji
        textLabel =
            String.dropLeft 2 label -- remaining text
    in
    div
        [ style "text-align" "center"
        , style "display" "flex"
        , style "flex-direction" "column"
        , style "align-items" "center"
        , style "gap" "6px"
        ]
        [ span
            [ style "font-size" "40px"  -- 🔥 bigger emoji
            , style "display" "block"
            ]
            [ text emoji ]
        , span
            [ style "font-size" "28px"
            , style "font-weight" "bold"
            ]
            [ text (String.fromInt value) ]
        , span
            [ style "font-size" "14px"
            , style "opacity" "0.9"
            , style "text-transform" "uppercase"
            , style "letter-spacing" "1px"
            ]
            [ text textLabel ]
        ]
