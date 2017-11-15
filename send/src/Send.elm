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
    | ReceipientReady String


type alias Model =
    { recipient : String
    , message : String
    , response : Maybe String
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Notify ->
            ( { model | response = Nothing }
            , (Http.send NotifyResponse
                (Http.post (notifyUrlBase ++ model.recipient) (Http.jsonBody (Json.Encode.object [ ( "message", (Json.Encode.string model.message) ) ])) notifyResponseDecoder)
              )
            )

        --( model, Cmd.none )
        NotifyResponse (Ok responseBody) ->
            ( { model | response = Just ("Successfully Notified") }, Cmd.none )

        NotifyResponse (Err err) ->
            ( { model | response = Just (httpErrToString err) }, Cmd.none )

        MessageReady msg ->
            ( { model | message = msg }, Cmd.none )

        ReceipientReady uid ->
            ( { model | recipient = uid }, Cmd.none )



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
        responseString : Maybe String -> String
        responseString resp =
            Maybe.withDefault "" resp

        inputRow : String -> Html Msg -> Html Msg
        inputRow lbl component =
            tr [] [ td [] [ label [] [ text lbl ] ], td [] [ component ] ]

        textInput cssid ph msg =
            input [ class cssid, placeholder ph, onInput msg ] []

        textArea cssid ph msg =
            textarea [ class cssid, placeholder ph, onInput msg ] []

        actionButton cssid =
            button [ class cssid, onClick Notify ] [ text "Send Message" ]
    in
        body []
            [ Html.div []
                [ Html.table [] [ inputRow "To" (textInput "recipient-field" "Enter UserId" ReceipientReady), inputRow "Message" (textArea "message-field" "Enter Message" MessageReady), inputRow "" (actionButton "send-message") ]
                , label [] [ text (responseString model.response) ]
                ]
            ]



--main


main : Program Never Model Msg
main =
    Html.program { init = ( Model "" "" Nothing, Cmd.none ), view = view, update = update, subscriptions = \t -> Sub.none }
