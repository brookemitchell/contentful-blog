port module Main exposing (..)

import Html exposing (..)
import Html.Attributes as At
import Html.Events as Ev
import Json.Decode exposing (..)


type alias BlogEntry =
    { author : String
    , title : String
    , body : String
    , date : String
    }


type alias Model =
    { blogList : Maybe (List BlogEntry)
    , editing : Bool
    }


type Msg
    = BlogInfo (Result String (List BlogEntry))
    | Editing
    | Upload
    | TextChange String


initialModel : Model
initialModel =
    { editing = False
    , blogList = Nothing
    }


init : a -> ( Model, Cmd Msg )
init flags =
    ( initialModel, Cmd.none )


view model =
    div [ At.class "container" ]
        [ h1 [] [ text "Blog Entries" ]
        , (viewBlogList model.editing model.blogList)
        , button [ Ev.onClick Upload, At.style [ ( "margin-top", "8px" ) ] ]
            [ text "Upload Changes" ]
        ]


viewBlogList editing blogList =
    case blogList of
        Just entryList ->
            div [ At.class "row" ] (List.map (viewBlogEntry editing) (entryList))

        Nothing ->
            div []
                [ text "Loading" ]


viewBlogEntry : Bool -> BlogEntry -> Html Msg
viewBlogEntry editing entry =
    let
        buttonText =
            case editing of
                True ->
                    "Save Entry"

                False ->
                    "Edit Entry"
    in
        div []
            [ div []
                [ div [] [ text entry.author ]
                , div [] [ entry.title ++ " : " ++ entry.date |> text ]
                ]
            , (entryBodyView editing entry.body)
            , button [ Ev.onClick Editing, At.style [ ( "margin-top", "8px" ) ] ]
                [ text buttonText ]
            ]


bodyStyle =
    At.style
        [ ( "width", "800px" )
        , ( "height", "400px" )
        , ( "overflow", "auto" )
        , ( "text-align", "justify" )
        ]


entryBodyView editing body =
    let
        el =
            case editing of
                True ->
                    textarea [ bodyStyle, Ev.onInput TextChange ]

                False ->
                    div [ bodyStyle ]
    in
        el
            [ text body ]


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        BlogInfo (Ok blogInfoList) ->
            ( { model | blogList = Just blogInfoList }
            , Cmd.none
            )

        BlogInfo (Err e) ->
            let
                _ =
                    Debug.log "Error" e
            in
                ( model
                , Cmd.none
                )

        Editing ->
            ( { model | editing = (not model.editing) }
            , Cmd.none
            )

        TextChange str ->
            let
                newBlogList =
                    model.blogList
                        |> Maybe.map (\e -> List.map (\x -> { x | body = str }) e)
            in
                ( { model | blogList = newBlogList }
                , Cmd.none
                )

        Upload ->
            let
                command =
                    case (getUpdateString model) of
                        Just s ->
                            updateEntry s

                        Nothing ->
                            Cmd.none
            in
                ( model
                , command
                )


getUpdateString : Model -> Maybe String
getUpdateString model =
    case model.blogList of
        Just bl ->
            bl
                |> List.head
                |> Maybe.map .body

        Nothing ->
            Nothing



-- "Upload this as the new string"


subscriptions model =
    blogEntry (BlogInfo << decodeValue (list blogDecoder))


main : Program String Model Msg
main =
    programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


blogDecoder =
    map4
        BlogEntry
        (at [ "fields", "author", "0", "fields", "name" ] string)
        (at [ "fields", "title" ] string)
        (at [ "fields", "body" ] string)
        (at [ "fields", "date" ] string)



-- Inbound ports


port blogEntry : (Json.Decode.Value -> msg) -> Sub msg



-- Outbound ports


port updateEntry : String -> Cmd msg
