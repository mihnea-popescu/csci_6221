module Randomizer exposing
    ( Model
    , Msg(..)
    , generateCmd
    , init
    , initWithSeed
    , seedFromClientInfo
    , update
    )

import Char
import Random
import Set exposing (Set)
import String



-- MODEL


type alias Model =
    { used : Set Int
    , seed : Maybe Random.Seed
    , baseSeed : Int
    }


init : Model
init =
    { used = Set.empty, seed = Nothing, baseSeed = 0 }


initWithSeed : Int -> Model
initWithSeed seedInt =
    { used = Set.empty
    , seed = Just (Random.initialSeed seedInt)
    , baseSeed = seedInt
    }



-- MESSAGES


type Msg
    = Generate
    | Generated Int
    | ResetSeed



-- UPDATE


update : Msg -> Model -> ( Model, Maybe Int, Cmd Msg )
update msg model =
    case msg of
        ResetSeed ->
            let
                newSeedInt =
                    (model.baseSeed * 37 + 13) |> modBy 999999
            in
            ( { model
                | seed = Just (Random.initialSeed newSeedInt)
                , used = Set.empty
                , baseSeed = newSeedInt
              }
            , Nothing
            , Cmd.none
            )

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
                        ( { model | used = Set.insert num model.used, seed = Just nextSeed }
                        , Just num
                        , Cmd.none
                        )

        Generated n ->
            if Set.member n model.used then
                ( model, Nothing, generateCmd )

            else
                ( { model | used = Set.insert n model.used }, Just n, Cmd.none )



-- COMMAND HELPER


generateCmd : Cmd Msg
generateCmd =
    Random.generate Generated (Random.int 1 1025)



-- CLIENT INFO TO SEED


type alias ClientInfo =
    { userAgent : String
    , screenWidth : Int
    , screenHeight : Int
    , language : String
    , timezone : String
    }


seedFromClientInfo : ClientInfo -> Int
seedFromClientInfo info =
    let
        str =
            info.userAgent
                ++ String.fromInt info.screenWidth
                ++ String.fromInt info.screenHeight
                ++ info.language
                ++ info.timezone

        hash =
            String.foldl
                (\ch acc -> (acc * 31 + Char.toCode ch) |> modBy 999999)
                7
                str
    in
    hash
