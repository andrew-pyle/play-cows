module Cows exposing (Model, Msg, init, subscriptions, update, view)

import Browser
import Css exposing (..)
import Html
import Html.Attributes exposing (value)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href, src)
import Html.Styled.Events exposing (onClick)
import String exposing (left)



-- main : Program flags Model Msg


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view >> Html.Styled.toUnstyled
        , update = update
        , subscriptions = subscriptions
        }


type Level
    = One
    | Two
    | Three


type Resource
    = Cow
    | CornField
    | HayBail
    | Tractor
    | Money


type alias Model =
    { cows : Int
    , cornFields : Int
    , hayBails : Int
    , windMills : Int
    , tractors : Int
    , money : Int
    , level : Int
    , baseCowBuyPrice : Int
    }


init : () -> ( Model, Cmd Msg )
init flags =
    ( Model 0 0 0 0 0 0 1 10, Cmd.none )



-- init : flags -> ( Model, Cmd Msg )
-- init flags =
--     ( Model "default" 0 1, Cmd.none )


type Msg
    = NoOp
    | AddResource Resource Int
    | SellCows
    | BuyCows
    | HerdStarves



-- | ChangePlayerName String


{-| Increments `current` with positive `delta` and decrements `current`
with negative `delta`, but does not go below zero
-}
nonNegativeUpdate : Int -> Int -> Int
nonNegativeUpdate current delta =
    if current + delta >= 0 then
        current + delta

    else
        0


maxLevel : Int
maxLevel =
    3


cornFieldConversionPoint : Int
cornFieldConversionPoint =
    10


cowSellPrice : Int -> Int
cowSellPrice playerLevel =
    let
        baseCowSellPrice : Int
        baseCowSellPrice =
            10
    in
    baseCowSellPrice
        * (2 ^ (playerLevel - 1))


{-| Increments player level, up to the max level. Removes max level
limitation logic from the update function.
-}
maxLevelUpdate : Int -> Int -> Int
maxLevelUpdate currentLevel delta =
    let
        updatedLevel =
            nonNegativeUpdate currentLevel delta
    in
    if updatedLevel <= maxLevel then
        updatedLevel

    else
        currentLevel


cowDeathRate : Int -> Float
cowDeathRate playerLevel =
    case playerLevel of
        1 ->
            0

        2 ->
            1 / 3

        3 ->
            1 / 2

        _ ->
            1


wholeCowsPlayerCanAfford : Int -> Int -> Int
wholeCowsPlayerCanAfford playerMoney cowCost =
    playerMoney // cowCost



{-
   Ability to add and subtract any amount of: cows, corn fields, hay bails, wind mills.
   Also the same for tractors, but when you get 4 tractors it automatically converts into $1 and your total of tractors goes to 0

   Being able to sell the cows when you reach a town of >5,000 population

   The ability to level up the farm and sell the cows for a higher price when you gather 10 corn fields at a maximum of 3 levels.
   The price goes up ×2 with each level.
   But when you are at level 2 and see a dead cornfield your herd is reduced by 1/3 and at level 3 it is reduced by 1/2.

   Using the money you make from selling the cows to buy more cows when you encounter a rest stop

-}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        AddResource resource qty ->
            case resource of
                Cow ->
                    ( { model | cows = nonNegativeUpdate model.cows qty }, Cmd.none )

                CornField ->
                    let
                        newCornFieldCount =
                            nonNegativeUpdate model.cornFields qty
                    in
                    -- model.level - 1 is necessary to start at level 1, rather than level 0
                    -- Int division truncates decimals, to allow the proper conversion
                    if (newCornFieldCount // cornFieldConversionPoint) > (model.level - 1) then
                        ( { model | cornFields = newCornFieldCount, level = maxLevelUpdate model.level 1 }, Cmd.none )

                    else
                        ( { model | cornFields = nonNegativeUpdate model.cornFields qty }, Cmd.none )

                HayBail ->
                    ( { model | hayBails = nonNegativeUpdate model.hayBails qty }, Cmd.none )

                Tractor ->
                    let
                        newNumberOfTractors =
                            nonNegativeUpdate model.tractors qty
                    in
                    if newNumberOfTractors >= 4 then
                        ( { model | tractors = 0, money = model.money + 1 }, Cmd.none )

                    else
                        ( { model | tractors = newNumberOfTractors }, Cmd.none )

                Money ->
                    ( { model | money = nonNegativeUpdate model.money qty }, Cmd.none )

        SellCows ->
            let
                saleReturn =
                    cowSellPrice model.level * model.cows
            in
            ( { model | cows = 0, money = model.money + saleReturn }, Cmd.none )

        BuyCows ->
            let
                cowsToBuy =
                    wholeCowsPlayerCanAfford model.money model.baseCowBuyPrice

                costOfCows =
                    cowsToBuy * model.baseCowBuyPrice

                moneyLeftover =
                    model.money - costOfCows
            in
            ( { model | cows = model.cows + cowsToBuy, money = moneyLeftover }, Cmd.none )

        HerdStarves ->
            let
                cowsThatDied =
                    cowDeathRate model.level * toFloat model.cows
            in
            ( { model | cows = model.cows - Basics.round cowsThatDied }, Cmd.none )



-- ChangePlayerName newName ->
--     ( { model | name = newName }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



{- Styles -}


{-| Theme Colors
-}
theme : { secondary : Color, primary : Color, accent : Color }
theme =
    { primary = hex "E8322C" -- "F0544F" --A63A50
    , secondary = hex "F3D9B1" --EAD94C
    , accent = hex "1878A7" -- "4E8098"
    }


appDisplay : Style
appDisplay =
    Css.batch
        [ property "display" "grid"
        , flexDirection column
        , justifyContent center
        ]


typography : Style
typography =
    Css.batch
        [ fontFamilies
            [ "-apple-system"
            , "BlinkMacSystemFont"
            , "Segoe UI"
            , "Roboto"
            , "Helvetica"
            , "Arial"
            , "sans-serif"
            , "Apple Color Emoji"
            , "Segoe UI Emoji"
            , "Segoe UI Symbol"
            ]
        ]


primaryColor : Style
primaryColor =
    Css.batch
        [ color theme.primary
        ]


secondayColor : Style
secondayColor =
    Css.batch
        [ color theme.secondary
        ]


accentColor : Style
accentColor =
    Css.batch
        [ color theme.primary
        , backgroundColor theme.secondary
        ]


cowDisplay : Style
cowDisplay =
    Css.batch
        [ displayFlex
        , fontSize (rem 2)
        , justifyContent center
        ]


cowCount : Style
cowCount =
    Css.batch
        [ color theme.primary
        , margin (px 0)
        , padding (Css.em 1)
        , fontSize (rem 2.5)
        , fontWeight (int 800)
        ]


{-| Styled Components
-}
btn : List (Attribute msg) -> List (Html msg) -> Html msg
btn =
    styled button
        [ padding <| Css.em 1
        , margin (Css.em 0.1)
        , backgroundColor theme.accent
        , color (hex "FFFFFF")
        , borderRadius (px 5)
        , border3 (px 0) solid theme.primary
        ]


view : Model -> Html.Styled.Html Msg
view model =
    div
        [ class "app"
        , css [ appDisplay, typography, width (vw 100), height (vh 100), margin (px 0), backgroundColor theme.secondary ]
        ]
        [ div [ class "dashboard-zone" ]
            [ h1 [ css [ primaryColor ] ] [ text "Play Cows" ]
            , div [ class "player-info", css [ displayFlex, alignItems baseline ] ]
                [ -- h2 [ css [ primaryColor ] ] [ text <| model.name ]
                  -- ,
                  p [ css [ fontStyle italic, fontSize (rem 1.2), color (hex "585858"), borderLeft3 (px 2) solid (hex "585858"), padding (Css.em 0.75), marginLeft (Css.em 1) ] ]
                    [ text <| "Level"
                    , b [] [ text <| " " ++ String.fromInt model.level ]
                    ]
                ]
            , div [ class "player-data" ]
                [ Html.Styled.table [ class "player-resources" ]
                    [ thead []
                        [ tr []
                            [ th [] [ text <| "Cows" ]
                            , th [] [ text <| "Corn Fields" ]
                            , th [] [ text <| "Hay Bails" ]
                            , th [] [ text <| "Tractors" ]
                            , th [] [ text <| "Money" ]
                            ]
                        ]
                    , tbody []
                        [ tr []
                            [ td [] [ text <| String.fromInt model.cows ]
                            , td [] [ text <| String.fromInt model.cornFields ]
                            , td [] [ text <| String.fromInt model.hayBails ]
                            , td [] [ text <| String.fromInt model.tractors ]
                            , td [] [ text <| "$ " ++ String.fromInt model.money ]
                            ]
                        , tr []
                            [ td []
                                [ btn [ onClick <| AddResource Cow -1 ] [ text <| "–" ]
                                , span [] [ text "1" ]
                                , btn [ onClick <| AddResource Cow 1 ] [ text <| "+" ]
                                ]
                            , td []
                                [ btn [ onClick <| AddResource CornField -1 ] [ text <| "–" ]
                                , span [] [ text "1" ]
                                , btn [ onClick <| AddResource CornField 1 ] [ text <| "+" ]
                                ]
                            , td []
                                [ btn [ onClick <| AddResource HayBail -1 ] [ text <| "–" ]
                                , span [] [ text "1 " ]
                                , btn [ onClick <| AddResource HayBail 1 ] [ text <| "+" ]
                                ]
                            , td []
                                [ btn [ onClick <| AddResource Tractor -1 ] [ text <| "–" ]
                                , span [] [ text "1" ]
                                , btn [ onClick <| AddResource Tractor 1 ] [ text <| "+" ]
                                ]
                            , td []
                                [ btn [ onClick <| AddResource Money -1 ] [ text <| "–" ]
                                , span [] [ text "$1" ]
                                , btn [ onClick <| AddResource Money 1 ] [ text <| "+" ]
                                ]
                            ]
                        , tr []
                            [ td []
                                [ btn [ onClick <| AddResource Cow -10 ] [ text <| "–" ]
                                , span [] [ text "10" ]
                                , btn [ onClick <| AddResource Cow 10 ] [ text <| "+" ]
                                ]
                            , td []
                                [ btn [ onClick <| AddResource CornField -10 ] [ text <| "–" ]
                                , span [] [ text "10" ]
                                , btn [ onClick <| AddResource CornField 10 ] [ text <| "+" ]
                                ]
                            , td []
                                [ btn [ onClick <| AddResource HayBail -10 ] [ text <| "–" ]
                                , span [] [ text "10" ]
                                , btn [ onClick <| AddResource HayBail 10 ] [ text <| "+" ]
                                ]
                            , td []
                                [ btn [ onClick <| AddResource Tractor -10 ] [ text <| "–" ]
                                , span [] [ text "10" ]
                                , btn [ onClick <| AddResource Tractor 10 ] [ text <| "+" ]
                                ]
                            , td []
                                [ btn [ onClick <| AddResource Money -10 ] [ text <| "–" ]
                                , span [] [ text "$10" ]
                                , btn [ onClick <| AddResource Money 10 ] [ text <| "+" ]
                                ]
                            ]
                        ]
                    ]
                ]

            -- , div []
            --     [ p []
            --         [ span [] [ text <| "Cows " ]
            --         , span [] [ text <| String.fromInt model.cows ]
            --         ]
            --     ]
            -- , div []
            --     [ p []
            --         [ span [] [ text <| "Corn Fields " ]
            --         , span [] [ text <| String.fromInt model.cornFields ]
            --         ]
            --     ]
            -- , div []
            --     [ p []
            --         [ span [] [ text <| "Hay Bails " ]
            --         , span [] [ text <| String.fromInt model.hayBails ]
            --         ]
            --     ]
            -- , div []
            --     [ p []
            --         [ span [] [ text <| "Tractors " ]
            --         , span [] [ text <| String.fromInt model.tractors ]
            --         ]
            --     ]
            -- , div []
            --     [ p []
            --         [ span [] [ text <| "Money $" ]
            --         , span [] [ text <| String.fromInt model.money ]
            --         ]
            --     ]
            -- , div []
            --     [ p []
            --         [ span [] [ text <| "Cow Price $" ]
            --         , span [] [ text <| String.fromInt (cowSellPrice model.level) ]
            --         ]
            --     ]
            , div
                [ class "controls-zone" ]
                [ div [ class "controls-add-lose", css [ displayFlex, flexDirection row ] ]
                    [ div [ class "controls-add", css [ displayFlex, flexDirection column ] ]
                        [ --     btn [ onClick <| AddResource Cow 1 ] [ text <| "+ 1 Cow" ]
                          -- , btn [ onClick <| AddResource HayBail 1 ] [ text <| "+ 1 Hay Bail" ]
                          -- , btn [ onClick <| AddResource CornField 1 ] [ text <| "+ 1 Corn Field" ]
                          -- , btn [ onClick <| AddResource Tractor 1 ] [ text <| "+ 1 Tractor" ]
                          -- , btn [ onClick <| AddResource Money 1 ] [ text <| "+ $1" ]
                          btn [ onClick <| SellCows ] [ text <| "💵 Sell Herd for $" ++ String.fromInt (cowSellPrice model.level * model.cows) ]
                        , btn [ onClick <| HerdStarves ] [ text <| "☠️ Herd Starves! Lose " ++ (String.left 2 <| String.fromFloat <| (cowDeathRate model.level * 100)) ++ "% of the Herd" ]
                        , btn [ onClick <| BuyCows ] [ text <| "🐄 Buy a New Herd (" ++ String.fromInt (wholeCowsPlayerCanAfford model.money model.baseCowBuyPrice) ++ " cows)" ]
                        ]
                    , div [ class "controls-lose", css [ displayFlex, flexDirection column ] ]
                        [ Html.Styled.table [ class "Cow Market" ]
                            [ thead []
                                [ tr []
                                    [ th [] [ text <| "Buy" ]
                                    , th [] [ text <| "Sell" ]
                                    ]
                                ]
                            , tbody []
                                [ tr []
                                    [ td [] [ text <| String.fromInt model.baseCowBuyPrice ]
                                    , td [] [ text <| String.fromInt <| cowSellPrice model.level ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        , div [ class "rules-zone" ]
            [ h2 [ class "rules-heading" ] [ text <| "Rules" ]
            , ul []
                [ li [] [ text <| "Four tractors are automatically sold for $1" ]
                , li [] [ text <| "Base Cow Buy/Sell Price is $10 per Cow" ]
                , li [] [ text <| "Collect 10 cornfields to go up a level. Maximum level is " ++ String.fromInt maxLevel ++ "." ]
                , li [] [ text <| "Sell cows at towns with populations of at least 5,000—the price a cow will fetch increases with your level." ]
                , li [] [ text <| "Dead cornfields cause starvation—at higher levels, more cows will die each time." ]
                , li [] [ text <| "Buy a new herd at the market to exchange all your money for cows according to the price of a cow" ]
                ]
            ]
        ]
