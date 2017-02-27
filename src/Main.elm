port module Main exposing (..)

import Html exposing (..)
import Html.Attributes as At
import Json.Decode exposing (..)


type alias BlogEntry =
    { author : String
    , title : String
    , body : String
    , date : String
    }


type alias Model =
    Maybe (List BlogEntry)


type Msg
    = BlogInfo (Result String (List BlogEntry))


initialModel : Model
initialModel =
    Nothing


init flags =
    ( initialModel, Cmd.none )


view model =
    div [ At.class "container" ]
        [ h1 [] [ text "Blog Entries" ]
        , (viewBlogList model)
        ]


viewBlogList blogList =
    case blogList of
        Just entryList ->
            div [ At.class "row" ] (List.map viewBlogEntry (entryList))

        Nothing ->
            div []
                [ text "Loading" ]


viewBlogEntry entry =
    div []
        [ div []
            [ div [] [ text entry.author ]
            , div [] [ entry.title ++ " : " ++ entry.date |> text ]
            ]
        , div
            [ At.style
                [ ( "width", "800px" )
                , ( "height", "400px" )
                , ( "overflow", "auto" )
                , ( "text-align", "justify" )
                ]
            ]
            [ text entry.body ]
        , button [ At.style [ ( "margin-top", "8px" ) ] ]
            [ text "edit entry" ]
        ]


update msg model =
    case msg of
        BlogInfo (Ok blogInfoList) ->
            ( Just blogInfoList
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


port blogEntry : (Json.Decode.Value -> msg) -> Sub msg
