module Main exposing (main)

import Api
import Browser
import Html exposing (Html, button, div, img, text)
import Html.Attributes exposing (src, style)
import Html.Events exposing (onClick)
import Http
import Randomizer



-- MODEL


type alias Model =
    { randomizer : Randomizer.Model
    , result : RemoteData
    }


type RemoteData
    = NotAsked
    | Loading
    | Success Api.Pokemon
    | Failure String


init : () -> ( Model, Cmd Msg )
init _ =
    ( { randomizer = Randomizer.init, result = NotAsked }, Cmd.none )



-- UPDATE


type Msg
    = RandomizerMsg Randomizer.Msg
    | FetchRandom
    | GotPokemon (Result Http.Error Api.Pokemon)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchRandom ->
            let
                ( newRand, maybeNum, nextCmd ) =
                    Randomizer.update Randomizer.Generate model.randomizer
            in
            case maybeNum of
                Nothing ->
                    ( { model | randomizer = newRand }, Cmd.map RandomizerMsg nextCmd )

                Just n ->
                    ( { model | randomizer = newRand, result = Loading }
                    , Api.getPokemonById (String.fromInt n) GotPokemon
                    )

        RandomizerMsg subMsg ->
            let
                ( newRand, maybeNum, nextCmd ) =
                    Randomizer.update subMsg model.randomizer
            in
            case maybeNum of
                Nothing ->
                    ( { model | randomizer = newRand }, Cmd.map RandomizerMsg nextCmd )

                Just n ->
                    ( { model | randomizer = newRand, result = Loading }
                    , Api.getPokemonById (String.fromInt n) GotPokemon
                    )

        GotPokemon (Ok poke) ->
            ( { model | result = Success poke }, Cmd.none )

        GotPokemon (Err err) ->
            ( { model | result = Failure (Api.httpErrorToString err) }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ style "font-family" "sans-serif", style "text-align" "center", style "margin-top" "40px" ]
        [ Html.map RandomizerMsg (Randomizer.view model.randomizer)
        , button
            [ onClick FetchRandom
            , style "padding" "10px 20px"
            , style "font-size" "16px"
            , style "cursor" "pointer"
            ]
            [ text "🎲 Fetch Random Pokémon" ]
        , div [ style "margin-top" "30px" ] [ viewResult model.result ]
        ]


viewResult : RemoteData -> Html msg
viewResult state =
    case state of
        NotAsked ->
            text "Press the button to get a random Pokémon!"

        Loading ->
            text "Loading..."

        Success poke ->
            div []
                [ text ("#" ++ String.fromInt poke.id ++ " — " ++ String.toUpper poke.name)
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
