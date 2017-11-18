module Send exposing (..)

import Html exposing (..)


--import Html.Attributes exposing (..)
--import Html.Events exposing (..)
--import Http exposing (..)
--import Json.Encode exposing (..)

import Json.Decode exposing (..)


--import SendUtils exposing (..)


notifyUrlBase : String
notifyUrlBase =
    "https://gonotify.herokuapp.com/notify/"



-- model


type
    Msg
    --TODO Complete the Msg
    = Notify


type alias Model =
    { recipient : String
    , message :
        String
        -- TODO Complete the Model
    }


type alias NotifyResponseBody =
    { status :
        Bool
        -- TODO Complete the Response Body
    }



-- update


notifyResponseDecoder : Decoder NotifyResponseBody
notifyResponseDecoder =
    Json.Decode.map NotifyResponseBody
        -- TODO Complete the ResponseBodyDecoder
        (field "status" Json.Decode.bool)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    -- TODO Handle all the messages correctly, Use SendUtils
    ( model, Cmd.none )



-- view


view : Model -> Html Msg
view model =
    -- TODO Build the view as needed, Use SendUtils
    div [] [ text "ToDo" ]



--main


main : Program Never Model Msg
main =
    -- Provide the correct initial state
    Html.program { init = ( Model "" "", Cmd.none ), view = view, update = update, subscriptions = \t -> Sub.none }
