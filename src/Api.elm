module Api exposing (Pokemon, getPokemonById, httpErrorToString)

import Http
import Json.Decode as Decode exposing (Decoder)


type alias Pokemon =
    { id : Int
    , name : String
    , imageUrl : String
    }


pokemonDecoder : Decoder Pokemon
pokemonDecoder =
    Decode.map3 Pokemon
        (Decode.field "id" Decode.int)
        (Decode.field "name" Decode.string)
        (Decode.at [ "sprites", "front_default" ] (Decode.maybe Decode.string)
            |> Decode.map (Maybe.withDefault "")
        )


getPokemonById : String -> (Result Http.Error Pokemon -> msg) -> Cmd msg
getPokemonById pokemonId toMsg =
    Http.get
        { url = "https://pokeapi.co/api/v2/pokemon/" ++ pokemonId
        , expect = Http.expectJson toMsg pokemonDecoder
        }


httpErrorToString : Http.Error -> String
httpErrorToString err =
    case err of
        Http.BadUrl u ->
            "Bad URL: " ++ u

        Http.Timeout ->
            "Request timed out"

        Http.NetworkError ->
            "Network error"

        Http.BadStatus s ->
            "Bad status: " ++ String.fromInt s

        Http.BadBody msg ->
            "Bad body: " ++ msg
