module UI.Feedback exposing (view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Types.GameState exposing (Feedback(..))
import Types.Msg exposing (Msg)


view : Feedback -> Html Msg
view feedback =
    case feedback of
        NoFeedback ->
            div [] []

        Correct ->
            div
                [ style "color" "#78C841"
                , style "font-size" "24px"
                , style "font-weight" "bold"
                , style "margin-top" "15px"
                , style "padding" "15px"
                , style "background-color" "#d5f4e6"
                , style "border-radius" "8px"
                , style "animation" "slideIn 0.3s ease-out"
                , style "text-align" "center"
                ]
                [ text "✅ Correct! Great job!" ]

        Incorrect ->
            div
                [ style "color" "#e74c3c"
                , style "font-size" "20px"
                , style "margin-top" "15px"
                , style "padding" "15px"
                , style "background-color" "#fadbd8"
                , style "border-radius" "8px"
                , style "text-align" "center"
                ]
                [ text "❌ Wrong! Try again!" ]

        ShowHint hint ->
            div
                [ style "color" "#f39c12"
                , style "font-size" "18px"
                , style "margin-top" "15px"
                , style "padding" "15px"
                , style "background-color" "#fef5e7"
                , style "border-radius" "8px"
                , style "text-align" "center"
                ]
                [ text ("💡 " ++ hint) ]

        Failed pokemonName ->
            div
                [ style "color" "#e74c3c"
                , style "font-size" "22px"
                , style "font-weight" "bold"
                , style "margin-top" "15px"
                , style "padding" "20px"
                , style "background-color" "#fadbd8"
                , style "border-radius" "8px"
                , style "text-align" "center"
                , style "border" "2px solid #c0392b"
                ]
                [ div []
                    [ text "😢 Max attempts reached!" ]
                , div
                    [ style "margin-top" "10px"
                    , style "font-size" "26px"
                    , style "color" "#2c3e50"
                    , style "background-color" "#fff"
                    , style "padding" "10px"
                    , style "border-radius" "5px"
                    , style "margin-top" "10px"
                    ]
                    [ text ("The answer was: " ++ String.toUpper pokemonName) ]
                , div
                    [ style "margin-top" "10px"
                    , style "font-size" "16px"
                    , style "color" "#7f8c8d"
                    ]
                    [ text "Moving to next Pokémon..." ]
                ]
