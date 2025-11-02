module UI.GuessInput exposing (view)

import Html exposing (Html, button, div, input, text)
import Html.Attributes exposing (placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Types.GameState exposing (GameState)
import Types.Msg exposing (Msg(..))


view : GameState -> Html Msg
view gameState =
    case gameState.currentPokemon of
        Nothing ->
            div [] []

        Just pokemon ->
            Html.form
                [ onSubmit SubmitGuess
                , style "margin-top" "25px"
                , style "padding" "25px"
                , style "background-color" "#ecf0f1"
                , style "border-radius" "12px"
                ]
                [ div
                    [ style "display" "flex"
                    , style "gap" "10px"
                    , style "align-items" "center"
                    ]
                    [ input
                        [ type_ "text"
                        , value gameState.userGuess
                        , onInput UserGuessInput
                        , placeholder "Type Pokemon name and press Enter..."
                        , style "flex" "1"
                        , style "padding" "12px 20px"
                        , style "font-size" "18px"
                        , style "border" "2px solid #3498db"
                        , style "border-radius" "8px"
                        , style "outline" "none"
                        ]
                        []
                    , button
                        [ type_ "submit"
                        , style "padding" "12px 30px"
                        , style "font-size" "18px"
                        , style "background-color" "#78C841"
                        , style "color" "white"
                        , style "border" "none"
                        , style "border-radius" "8px"
                        , style "cursor" "pointer"
                        , style "font-weight" "bold"
                        , style "transition" "all 0.3s"
                        ]
                        [ text "Submit" ]
                    ]
                ]