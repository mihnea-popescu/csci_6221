module UI.PokemonDisplay exposing (view)

import Api
import Html exposing (Html, div, img, text)
import Html.Attributes exposing (src, style)
import Types.GameState exposing (Feedback(..), GameState)
import Types.Msg exposing (Msg)


view : GameState -> Html Msg
view gameState =
    case gameState.currentPokemon of
        Nothing ->
            div
                [ style "text-align" "center"
                , style "padding" "40px"
                , style "color" "#7f8c8d"
                , style "font-size" "18px"
                ]
                [ text "🎮 Press 'Start New Pokemon' to begin!" ]

        Just pokemon ->
            let
                shouldHidePokemon =
                    case gameState.feedback of
                        Correct ->
                            False

                        Failed _ ->
                            False

                        _ ->
                            True

                silhouetteStyles =
                    if shouldHidePokemon then
                        [ style "filter" "brightness(0) drop-shadow(0 0 12px rgba(0,0,0,0.5))" ]

                    else
                        []
            in
            div [ style "text-align" "center", style "margin" "25px 0" ]
                [ div
                    [ style "font-size" "20px"
                    , style "color" "#34495e"
                    , style "margin-bottom" "15px"
                    ]
                    [ text ("#" ++ String.fromInt pokemon.id) ]
                , div []
                    [ img
                        ( [ src pokemon.imageUrl
                          , style "width" "250px"
                          , style "height" "250px"
                          , style "image-rendering" "pixelated"
                          ]
                            ++ silhouetteStyles
                        )
                        []
                    ]
                ]
