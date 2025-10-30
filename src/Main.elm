module Main exposing (main)

import Api
import Browser
import Html exposing (Html, button, div, input, pre, text)
import Html.Attributes exposing (style, value)
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
    | Success String
    | Failure String


init : () -> ( Model, Cmd Msg )
init _ =
    ( { searchId = "", result = NotAsked }, Cmd.none )



-- UPDATE


type Msg
    = UpdateSearch String
    | FetchPokemon
    | GotResponse (Result Http.Error String)


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

        GotResponse (Ok rawJson) ->
            ( { model | result = Success rawJson }, Cmd.none )

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
            [ text "Fetch Pokémon JSON" ]
        , div [ style "margin-top" "30px", style "text-align" "left", style "width" "80%", style "margin" "40px auto" ]
            [ viewResult model.result ]
        ]


viewResult : RemoteData -> Html msg
viewResult state =
    case state of
        NotAsked ->
            text "Enter a Pokémon ID and press the button."

        Loading ->
            text "Loading..."

        Success json ->
            pre [ style "background-color" "#f3f3f3", style "padding" "16px", style "overflow-x" "auto" ]
                [ text json ]

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
