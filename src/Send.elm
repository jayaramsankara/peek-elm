module Send exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Json.Encode exposing (..)
import Json.Decode exposing (..)


notifyUrlBase : String
notifyUrlBase =
    "https://gonotify.herokuapp.com/notify/"



-- model
-- type Msg


type alias Model =
    {}



type alias NotifyResponseBody = {
  status : String,
  clientId : String

}
-- update


notifyResponseDecoder : Decoder NotifyResponseBody
notifyResponseDecoder =
    Json.Decode.map2 NotifyResponseBody
        (field "status" Json.Decode.bool)
        (field "clientId" Json.Decode.string)


toJsonMessage : Model -> Body
toJsonMessage model =
    Http.jsonBody (Json.Encode.object [ ( "message", (Json.Encode.string ("{\"message\" : \"" ++ model.message ++ "\",\"sender\" : \"" ++ model.sender ++ "\"}")) ) ])

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

--update : Msg -> Model -> ( Model, Cmd Msg )
-- view






--view : Model -> Html Msg
--view model =
--Html.div [ class "sendsection" ]
-- TODO Add Div Content
--main


main : Program Never Model Msg
main =
    Html.program { init = TODO, view = view, update = update, subscriptions = \t -> Sub.none }
