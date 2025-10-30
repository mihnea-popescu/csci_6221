module Main exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)



-- MODEL


type alias Model =
    { count : Int }


init : Model
init =
    { count = 0 }



-- UPDATE


type Msg
    = Inc
    | Dec


update : Msg -> Model -> Model
update msg model =
    case msg of
        Inc ->
            { model | count = model.count + 1 }

        Dec ->
            { model | count = model.count - 1 }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [] [ text ("Count: " ++ String.fromInt model.count) ]
        , button [ onClick Inc ] [ text "+1" ]
        , button [ onClick Dec, Html.Attributes.style "margin-left" "8px" ] [ text "-1" ]
        ]



-- PROGRAM


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }
