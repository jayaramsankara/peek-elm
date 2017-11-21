module Send exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Json.Encode exposing (..)
import Json.Decode exposing (..)


-- model


type Msg
    = Notify
    | NotifyResponse (Result Error NotifyResponseBody)
    | MessageReady String
    | RecipientReady String


type alias Model =
    { recipient : String
    , message : String
    , status : Maybe String
    , sender : String
    }


type alias NotifyResponseBody =
    { status : Bool
    , clientId : String
    }


notifyUrlBase : String
notifyUrlBase =
    "https://gonotify.herokuapp.com/notify/"



-- update


notifyResponseDecoder : Decoder NotifyResponseBody
notifyResponseDecoder =
    Json.Decode.map2 NotifyResponseBody
        (field "status" Json.Decode.bool)
        (field "clientId" Json.Decode.string)


toJsonBody : String -> String -> Body
toJsonBody message sender =
    Http.jsonBody (Json.Encode.object [ ( "message", (Json.Encode.string ("{\"message\" : \"" ++ message ++ "\",\"sender\" : \"" ++ sender ++ "\"}")) ) ])


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Notify ->
            ( { model | status = Just ("Notifying.." ++ model.recipient) }
            , (Http.send NotifyResponse
                (Http.post (notifyUrlBase ++ model.recipient) (toJsonBody model.message model.sender) notifyResponseDecoder)
              )
            )

        --( model, Cmd.none )
        NotifyResponse (Ok responseBody) ->
            let
                newModel : String -> Model -> Model
                newModel message model =
                    { model | status = Just (message) }
            in
                if responseBody.status then
                    ( newModel "Message Sent." model, Cmd.none )
                else
                    ( newModel ("Message Not Delivered. " ++ responseBody.clientId ++ " is not connected.") model, Cmd.none )

        NotifyResponse (Err err) ->
            ( { model | status = Just (httpErrToString err) }, Cmd.none )

        MessageReady msg ->
            ( { model | message = msg, status = Nothing }, Cmd.none )

        RecipientReady uid ->
            ( { model | recipient = uid, status = Nothing }, Cmd.none )



-- view


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


view : Model -> Html Msg
view model =
    let
        statusMsg : Maybe String -> String
        statusMsg resp =
            Maybe.withDefault "" resp

        inputRow : List (Html Msg) -> Html Msg
        inputRow components =
            tr [] <| List.map (\comp -> td [] [ comp ]) components

        textInput cssid ph msg =
            input [ class cssid, placeholder ph, onInput msg ] []

        textArea cssid ph msg =
            textarea [ class cssid, placeholder ph, onInput msg ] []

        actionButton cssid msg =
            button [ class cssid, onClick msg ] [ text "Send" ]
    in
        Html.div [ class "sendsection" ]
            [ Html.table []
                [ inputRow [ (textInput "recipient-field" "Enter UserId" RecipientReady) ]
                , inputRow [ (textArea "message-field" "Enter Message" MessageReady), (actionButton "send-message" Notify), text (statusMsg model.status) ]
                ]
            ]



--main


main : Program Never Model Msg
main =
    Html.program { init = ( Model "" "" Nothing "anonymous", Cmd.none ), view = view, update = update, subscriptions = \t -> Sub.none }
