module Randomizer exposing (Model, Msg(..), getRandomCmd, init, update)

import Random
import Set exposing (Set)



-- MODEL


type alias Model =
    { used : Set Int }


init : Model
init =
    { used = Set.empty }



-- MESSAGE TYPE


type Msg
    = Generate
    | Generated Int



-- UPDATE


update : Msg -> Model -> ( Model, Maybe Int, Cmd Msg )
update msg model =
    case msg of
        Generate ->
            let
                available =
                    List.filter (\n -> not (Set.member n model.used)) (List.range 1 1025)
            in
            if List.isEmpty available then
                -- Reset if all IDs used
                ( { used = Set.empty }, Nothing, Random.generate Generated (Random.int 1 1025) )

            else
                ( model, Nothing, Random.generate Generated (Random.int 1 1025) )

        Generated n ->
            if Set.member n model.used then
                -- Already used → try again
                ( model, Nothing, Random.generate Generated (Random.int 1 1025) )

            else
                -- New number found
                ( { model | used = Set.insert n model.used }, Just n, Cmd.none )



-- COMMAND HELPER


getRandomCmd : Cmd Msg
getRandomCmd =
    Random.generate Generated (Random.int 1 1025)
