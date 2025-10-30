module Api exposing (getPokemonById, httpErrorToString)

import Http


getPokemonById : String -> (Result Http.Error String -> msg) -> Cmd msg
getPokemonById pokemonId toMsg =
    Http.get
        { url = "https://pokeapi.co/api/v2/pokemon/" ++ pokemonId
        , expect = Http.expectString toMsg
        }



-- ERROR HANDLING


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
