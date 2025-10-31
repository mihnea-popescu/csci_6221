port module Main exposing (main)

import Api
import Browser
import Html exposing (Html, button, div, img, text)
import Html.Attributes exposing (src, style)
import Html.Events exposing (onClick)
import Http
import Randomizer



-- PORTS


port saveSeed : Int -> Cmd msg


port loadSeed : () -> Cmd msg


port onSeedLoaded : (Int -> msg) -> Sub msg



-- FLAGS


type alias Flags =
    { userAgent : String
    , screenWidth : Int
    , screenHeight : Int
    , language : String
    , timezone : String
    }



-- MODEL


type alias Model =
    { randomizer : Randomizer.Model
    , result : RemoteData
    , loadedFromStorage : Bool
    , defaultSeed : Int
    }


type RemoteData
    = NotAsked
    | Loading
    | Success Api.Pokemon
    | Failure String



-- INIT


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        fingerprintSeed =
            Randomizer.seedFromClientInfo
                { userAgent = flags.userAgent
                , screenWidth = flags.screenWidth
                , screenHeight = flags.screenHeight
                , language = flags.language
                , timezone = flags.timezone
                }
    in
    ( { randomizer = Randomizer.initWithSeed fingerprintSeed
      , result = NotAsked
      , loadedFromStorage = False
      , defaultSeed = fingerprintSeed
      }
    , loadSeed ()
      -- request stored seed from JS
    )



-- UPDATE


type Msg
    = RandomizerMsg Randomizer.Msg
    | FetchRandom
    | GotPokemon (Result Http.Error Api.Pokemon)
    | SeedLoaded Int
    | SaveCurrentSeed
    | ResetSeed


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SeedLoaded loadedSeed ->
            -- ✅ If loaded seed is 0, use fingerprintSeed instead
            let
                actualSeed =
                    if loadedSeed == 0 then
                        model.defaultSeed

                    else
                        loadedSeed
            in
            if model.loadedFromStorage then
                ( model, Cmd.none )

            else
                ( { model
                    | randomizer = Randomizer.initWithSeed actualSeed
                    , loadedFromStorage = True
                  }
                , saveSeed actualSeed
                )

        SaveCurrentSeed ->
            ( model, saveSeed model.randomizer.baseSeed )

        ResetSeed ->
            let
                ( newRand, _, _ ) =
                    Randomizer.update Randomizer.ResetSeed model.randomizer
            in
            ( { model | randomizer = newRand }, saveSeed newRand.baseSeed )

        FetchRandom ->
            let
                ( newRand, maybeNum, nextCmd ) =
                    Randomizer.update Randomizer.Generate model.randomizer
            in
            case maybeNum of
                Nothing ->
                    ( { model | randomizer = newRand }
                    , Cmd.map RandomizerMsg nextCmd
                    )

                Just n ->
                    ( { model
                        | randomizer = newRand
                        , result = Loading
                      }
                    , Api.getPokemonById (String.fromInt n) GotPokemon
                    )

        RandomizerMsg subMsg ->
            let
                ( newRand, maybeNum, nextCmd ) =
                    Randomizer.update subMsg model.randomizer
            in
            case maybeNum of
                Nothing ->
                    ( { model | randomizer = newRand }
                    , Cmd.map RandomizerMsg nextCmd
                    )

                Just n ->
                    ( { model
                        | randomizer = newRand
                        , result = Loading
                      }
                    , Api.getPokemonById (String.fromInt n) GotPokemon
                    )

        GotPokemon (Ok poke) ->
            ( { model | result = Success poke }, Cmd.none )

        GotPokemon (Err err) ->
            ( { model | result = Failure (Api.httpErrorToString err) }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ style "font-family" "sans-serif"
        , style "text-align" "center"
        , style "margin-top" "40px"
        ]
        [ button
            [ onClick FetchRandom
            , style "padding" "10px 20px"
            , style "font-size" "16px"
            , style "cursor" "pointer"
            ]
            [ text "🎲 Fetch Random Pokémon" ]
        , div [ style "margin-top" "30px" ] [ viewResult model.result ]
        , div [ style "margin-top" "20px" ]
            [ text ("🌱 Current Seed: " ++ String.fromInt model.randomizer.baseSeed)
            , button
                [ onClick ResetSeed
                , style "margin-left" "12px"
                , style "padding" "6px 12px"
                , style "font-size" "14px"
                ]
                [ text "Reset Seed" ]
            ]
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


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> onSeedLoaded SeedLoaded
        }
