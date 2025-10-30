module Main exposing (main)

import Api
import Browser
import Html exposing (Html, button, div, img, input, text)
import Html.Attributes exposing (src, style, value)
import Html.Events exposing (onClick, onInput)
import Http



-- MODEL


type alias Model =
    { searchId : String
    , result : RemoteData
    }


type RemoteData
    = NotAsked
    | Loading
    | Success Api.Pokemon
    | Failure String


init : () -> ( Model, Cmd Msg )
init _ =
    ( { searchId = "", result = NotAsked }, Cmd.none )



-- UPDATE


type Msg
    = UpdateSearch String
    | FetchPokemon
    | GotResponse (Result Http.Error Api.Pokemon)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateSearch idStr ->
            ( { model | searchId = idStr }, Cmd.none )

        FetchPokemon ->
            if String.isEmpty model.searchId then
                ( model, Cmd.none )

            else
                ( { model | result = Loading }
                , Api.getPokemonById model.searchId GotResponse
                )

        GotResponse (Ok pokemon) ->
            ( { model | result = Success pokemon }, Cmd.none )

        GotResponse (Err err) ->
            ( { model | result = Failure (Api.httpErrorToString err) }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ style "font-family" "sans-serif", style "text-align" "center", style "margin-top" "40px" ]
        [ input
            [ value model.searchId
            , onInput UpdateSearch
            , style "padding" "8px"
            , style "width" "200px"
            , style "font-size" "16px"
            , style "margin-right" "10px"
            ]
            []
        , button
            [ onClick FetchPokemon
            , style "padding" "8px 16px"
            , style "font-size" "16px"
            ]
            [ text "Fetch Pokémon" ]
        , div [ style "margin-top" "30px" ] [ viewResult model.result ]
        ]


viewResult : RemoteData -> Html msg
viewResult state =
    case state of
        NotAsked ->
            text "Enter a Pokémon ID and press the button."

        Loading ->
            text "Loading..."

        Success poke ->
            div []
                [ text ("ID: " ++ String.fromInt poke.id)
                , div [] [ text ("Name: " ++ String.toUpper poke.name) ]
                , div [ style "margin-top" "12px" ]
                    [ img [ src poke.imageUrl, style "width" "200px" ] [] ]
                ]

        Failure err ->
            text ("Error: " ++ err)



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
