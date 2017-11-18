module SendUtils exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Json.Encode exposing (..)


httpErrToString : Http.Error -> String
httpErrToString err =
    case err of
        Timeout ->
            "Timeout Error"

        NetworkError ->
            "Network Error"

        BadStatus response ->
            "Bad Status Code in Response : " ++ toString response.status.code

        BadPayload msg _ ->
            "Bad Response Payload : " ++ msg

        BadUrl _ ->
            "Invalid URL"


toJsonBody : String -> String -> Body
toJsonBody message sender =
    Http.jsonBody (Json.Encode.object [ ( "message", (Json.Encode.string ("{\"message\" : \"" ++ message ++ "\",\"sender\" : \"" ++ sender ++ "\"}")) ) ])


inputRow : List (Html a) -> Html a
inputRow components =
    tr [] <| List.map (\comp -> td [] [ comp ]) components


textInput : String -> String -> (String -> a) -> Html a
textInput cssid ph msg =
    input [ class cssid, placeholder ph, onInput msg ] []


textArea : String -> String -> (String -> a) -> Html a
textArea cssid ph msg =
    textarea [ class cssid, placeholder ph, onInput msg ] []


actionButton : String -> a -> Html a
actionButton cssid msg =
    button [ class cssid, onClick msg ] [ text "Send" ]
