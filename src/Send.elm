module Send exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


--import Html.Events exposing (..)

import Http exposing (..)


--import Json.Encode exposing (..)

import Json.Decode exposing (..)
import SendUtils exposing (..)


notifyUrlBase : String
notifyUrlBase =
    "https://gonotify.herokuapp.com/notify/"



-- model


type
    Msg
    --TODO Complete the Msg
    = Notify
    | RecipientReady String
    | MessageReady String
    | NotifyResponse (Result Error NotifyResponseBody)


type alias Model =
    { recipient : String
    , message :
        String
    , status :
        Maybe String
    , sender :
        String
        -- TODO Complete the Model
    }


type alias NotifyResponseBody =
    { status :
        Bool
    , clientId :
        String
        -- TODO Complete the Response Body
    }



-- update


notifyResponseDecoder : Decoder NotifyResponseBody
notifyResponseDecoder =
    Json.Decode.map2 NotifyResponseBody
        -- TODO Complete the ResponseBodyDecoder
        (field "status" Json.Decode.bool)
        (field "clientId" Json.Decode.string)


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


view : Model -> Html Msg
view model =
    -- TODO Build the view as needed, Use SendUtils
    Html.div [ class "sendsection" ]
        [ Html.table []
            [ inputRow [ (textInput "recipient-field" "Enter UserId" RecipientReady) ]
            , inputRow [ (textArea "message-field" "Enter Message" MessageReady), (actionButton "send-message" Notify), text (statusMsg model.status) ]
            ]
        ]



--main


main : Program Never Model Msg
main =
    -- Provide the correct initial state
    Html.program { init = ( Model "" "" Nothing "", Cmd.none ), view = view, update = update, subscriptions = \t -> Sub.none }
