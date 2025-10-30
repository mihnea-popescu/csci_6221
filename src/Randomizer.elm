module Randomizer exposing (Model, Msg(..), generateCmd, init, update, view)

import Html exposing (Html, button, div, input, text)
import Html.Attributes exposing (placeholder, style, value)
import Html.Events exposing (onClick, onInput)
import Random
import Set exposing (Set)



-- MODEL


type alias Model =
    { used : Set Int
    , seed : Maybe Random.Seed
    , seedInput : String
    }


init : Model
init =
    { used = Set.empty, seed = Nothing, seedInput = "" }



-- MESSAGE TYPE


type Msg
    = Generate
    | Generated Int
    | SetSeed String
    | UpdateSeedInput String



-- UPDATE


update : Msg -> Model -> ( Model, Maybe Int, Cmd Msg )
update msg model =
    case msg of
        UpdateSeedInput val ->
            ( { model | seedInput = val }, Nothing, Cmd.none )

        SetSeed seedStr ->
            case String.toInt seedStr of
                Just n ->
                    ( { model | seed = Just (Random.initialSeed n), used = Set.empty }, Nothing, Cmd.none )

                Nothing ->
                    ( model, Nothing, Cmd.none )

        Generate ->
            case model.seed of
                Nothing ->
                    ( model, Nothing, generateCmd )

                Just s ->
                    let
                        ( num, nextSeed ) =
                            Random.step (Random.int 1 1025) s
                    in
                    if Set.member num model.used then
                        update Generate { model | seed = Just nextSeed }

                    else
                        ( { model | used = Set.insert num model.used, seed = Just nextSeed }, Just num, Cmd.none )

        Generated n ->
            if Set.member n model.used then
                ( model, Nothing, generateCmd )

            else
                ( { model | used = Set.insert n model.used }, Just n, Cmd.none )



-- COMMAND HELPER


generateCmd : Cmd Msg
generateCmd =
    Random.generate Generated (Random.int 1 1025)



-- VIEW (Seed Input UI)


view : Model -> Html Msg
view model =
    div [ style "margin-bottom" "20px" ]
        [ input
            [ value model.seedInput
            , placeholder "Enter seed (number)"
            , onInput UpdateSeedInput
            , style "padding" "8px"
            , style "font-size" "16px"
            , style "width" "180px"
            , style "margin-right" "8px"
            ]
            []
        , button
            [ onClick (SetSeed model.seedInput)
            , style "padding" "8px 16px"
            , style "font-size" "16px"
            ]
            [ text "Set Seed" ]
        ]
