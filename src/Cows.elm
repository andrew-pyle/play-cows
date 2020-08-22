module Cows exposing (main)

import Browser
import Css exposing (..)
import Css.Global exposing (selector)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
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
    = AddResource Resource Int
    | SellCows
    | BuyCows
    | HerdStarves


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


{-| Ability to add and subtract any amount of: cows, corn fields, hay bails, wind mills.
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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



{- Styles -}


{-| Theme Colors
-}
theme : { secondary : Color, primary : Color, accent : Color, muted : Color }
theme =
    { primary = hex "E8322C" -- "F0544F" --A63A50
    , secondary = hex "F3D9B1" --EAD94C
    , accent = hex "1878A7" -- "4E8098"
    , muted = hex "585858"
    }


appLayout : Style
appLayout =
    Css.batch
        [ maxWidth (Css.em 30)
        , margin2 (px 0) auto
        ]


appTypography : Style
appTypography =
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


emojiTypography : Style
emojiTypography =
    Css.batch
        [ fontSize (rem 2.5)
        , textAlign center
        ]


btnStyle : Style
btnStyle =
    Css.batch
        [ padding2 (Css.em 0.5) (Css.em 1)
        , margin (Css.em 0.1)
        , backgroundColor theme.accent
        , color (hex "FFFFFF")
        , borderRadius (px 5)
        , border3 (px 0) solid theme.primary
        , flexGrow (int 1)
        ]


primaryColor : Style
primaryColor =
    Css.batch
        [ color theme.primary
        ]


playerInfo : Style
playerInfo =
    Css.batch
        [ displayFlex
        , justifyContent spaceBetween
        , alignItems baseline
        , borderLeft3 (px 5) solid theme.muted
        , borderRight3 (px 5) solid theme.muted
        , padding (Css.em 0.75)

        -- , margin2 (px 0) (Css.em 1)
        ]


playerInfoTypography : Style
playerInfoTypography =
    Css.batch
        [ fontStyle italic
        , fontSize (rem 1.1)
        , color theme.muted
        , margin (px 0)
        ]


playerInfoValueTypography : Style
playerInfoValueTypography =
    Css.batch
        [ fontStyle normal
        , fontWeight bolder
        , marginLeft (Css.em 0.2)
        ]


headingTypography : Style
headingTypography =
    Css.batch
        [ primaryColor
        , margin (px 0)
        , textAlign center
        ]


dashboardZone : Style
dashboardZone =
    Css.batch
        [ displayFlex
        , flexDirection column
        , height (vh 100)
        ]


dashboard : Style
dashboard =
    Css.batch
        [ displayFlex
        , flexDirection column
        , justifyContent spaceBetween
        , flexGrow (int 1)
        ]


dashboardResource : Style
dashboardResource =
    Css.batch
        [ displayFlex
        , justifyContent spaceAround
        , alignItems center
        , flexGrow (int 1)
        , margin2 (Css.em 0.25) (px 0)
        ]


dashboardLabel : Style
dashboardLabel =
    Css.batch
        [ flexBasis (Css.em 1.4)
        , fontSize (rem 2.5)
        ]


dashboardValue : Style
dashboardValue =
    Css.batch
        [ displayFlex
        , justifyContent spaceBetween
        , flexGrow (int 1)
        , fontWeight bolder
        ]


dashboardControls : Style
dashboardControls =
    Css.batch
        [ displayFlex
        , justifyContent spaceBetween
        , alignItems center
        , flexGrow (int 1)
        ]


dashboardQty : Style
dashboardQty =
    Css.batch
        [ displayFlex
        , justifyContent center
        , alignItems center
        , flexBasis (Css.em 2)
        ]


controlsZone : Style
controlsZone =
    Css.batch
        [ displayFlex
        , alignItems flexStart
        , paddingTop (Css.em 0.5)
        , paddingBottom (Css.em 0.5)
        , marginTop (Css.em 0.5)
        , marginBottom (Css.em 0.5)
        , borderTop3 (px 2) dashed theme.muted
        , borderBottom3 (px 2) dashed theme.muted
        ]


control : Style
control =
    Css.batch
        [ displayFlex
        , flexDirection column
        , justifyContent center
        , flexBasis (Css.em 1)
        , flexGrow (int 1)
        ]


emojiControl : Style
emojiControl =
    Css.batch
        [ fontSize (rem 1.5)
        ]


{-| Styled Components
-}
btn : List (Attribute msg) -> List (Html msg) -> Html msg
btn =
    styled button
        [ btnStyle
        ]


btnPrimary : List (Attribute msg) -> List (Html msg) -> Html msg
btnPrimary =
    styled button
        [ btnStyle
        , backgroundColor theme.primary
        ]


btnMuted : List (Attribute msg) -> List (Html msg) -> Html msg
btnMuted =
    styled button
        [ btnStyle
        , backgroundColor theme.muted
        ]


view : Model -> Html.Styled.Html Msg
view model =
    div
        [ class "app"
        , css
            [ appLayout
            ]
        ]
        [ Css.Global.global
            [ selector "body"
                [ margin (px 0)
                , backgroundColor theme.secondary
                , property "touch-action" "manipulation"
                , appTypography
                ]
            , selector "button"
                [ fontFamily inherit
                , fontSize inherit
                , color inherit
                , backgroundColor inherit
                ]
            ]
        , div [ class "dashboard-zone", css [ dashboardZone ] ]
            [ h1 [ css [ headingTypography ] ] [ text "Play Cows" ]
            , div [ class "player-info", css [ playerInfo ] ]
                [ p [ css [ playerInfoTypography ] ] [ text <| "Lvl", span [ css [ playerInfoValueTypography ] ] [ text <| String.fromInt model.level ] ]
                , p [ css [ playerInfoTypography ] ] [ text <| "Buy —", span [ css [ playerInfoValueTypography ] ] [ text <| "$" ++ String.fromInt model.baseCowBuyPrice ] ]
                , p [ css [ playerInfoTypography ] ] [ text <| "Sell —", span [ css [ playerInfoValueTypography ] ] [ text <| "$" ++ (String.fromInt <| cowSellPrice model.level) ] ]
                ]
            , div [ class "player-dashboard", css [ dashboard ] ]
                [ div [ css [ dashboardResource ] ]
                    [ div [ css [ dashboardLabel ] ] [ span [ css [ emojiTypography ] ] [ text <| "🐮" ] ]
                    , div [ css [ dashboardValue ] ]
                        [ div [ css [ dashboardControls ] ]
                            [ btnPrimary [ onClick <| AddResource Cow -10 ] [ text <| "–10" ]
                            , btnPrimary [ onClick <| AddResource Cow -1 ] [ text <| "–1" ]
                            ]
                        , div [ css [ dashboardQty ] ] [ span [] [ text <| String.fromInt model.cows ] ]
                        , div [ css [ dashboardControls ] ]
                            [ btn [ onClick <| AddResource Cow 1 ] [ text <| "+1" ]
                            , btn [ onClick <| AddResource Cow 10 ] [ text <| "+10" ]
                            ]
                        ]
                    ]
                , div [ css [ dashboardResource ] ]
                    [ div [ css [ dashboardLabel ] ] [ span [ css [ emojiTypography ] ] [ text <| "💰" ] ]
                    , div [ css [ dashboardValue ] ]
                        [ div [ css [ dashboardControls ] ]
                            [ btnPrimary [ onClick <| AddResource Money -10 ] [ text <| "–10" ]
                            , btnPrimary [ onClick <| AddResource Money -1 ] [ text <| "–1" ]
                            ]
                        , div [ css [ dashboardQty ] ] [ span [] [ text <| "$" ++ String.fromInt model.money ] ]
                        , div [ css [ dashboardControls ] ]
                            [ btn [ onClick <| AddResource Money 1 ] [ text <| "+1" ]
                            , btn [ onClick <| AddResource Money 10 ] [ text <| "+10" ]
                            ]
                        ]
                    ]
                , div [ css [ dashboardResource ] ]
                    [ div [ css [ dashboardLabel ] ] [ span [ css [ emojiTypography ] ] [ text <| "🌾" ] ]
                    , div [ css [ dashboardValue ] ]
                        [ div [ css [ dashboardControls ] ]
                            [ btnPrimary [ onClick <| AddResource HayBail -1 ] [ text <| "–1" ]
                            ]
                        , div [ css [ dashboardQty ] ] [ span [] [ text <| String.fromInt model.hayBails ] ]
                        , div [ css [ dashboardControls ] ]
                            [ btn [ onClick <| AddResource HayBail 1 ] [ text <| "+1" ]
                            ]
                        ]
                    ]
                , div [ css [ dashboardResource ] ]
                    [ div [ css [ dashboardLabel ] ] [ span [ css [ emojiTypography ] ] [ text <| "🌽" ] ]
                    , div [ css [ dashboardValue ] ]
                        [ div [ css [ dashboardControls ] ]
                            [ btnPrimary [ onClick <| AddResource CornField -1 ] [ text <| "–1" ]
                            ]
                        , div [ css [ dashboardQty ] ] [ span [] [ text <| String.fromInt model.cornFields ] ]
                        , div [ css [ dashboardControls ] ]
                            [ btn [ onClick <| AddResource CornField 1 ] [ text <| "+1" ]
                            ]
                        ]
                    ]
                , div [ css [ dashboardResource ] ]
                    [ div [ css [ dashboardLabel ] ] [ span [ css [ emojiTypography ] ] [ text <| "🚜" ] ]
                    , div [ css [ dashboardValue ] ]
                        [ div [ css [ dashboardControls ] ]
                            [ btnPrimary [ onClick <| AddResource Tractor -1 ] [ text <| "–1" ]
                            ]
                        , div [ css [ dashboardQty ] ] [ span [] [ text <| String.fromInt model.tractors ] ]
                        , div [ css [ dashboardControls ] ]
                            [ btn [ onClick <| AddResource Tractor 1 ] [ text <| "+1" ]
                            ]
                        ]
                    ]
                ]
            , div
                [ class "controls-zone", css [ controlsZone ] ]
                [ div [ css [ control ] ]
                    [ span [ css [ emojiTypography, emojiControl ] ] [ text <| "☠️" ]
                    , btnMuted [ onClick <| HerdStarves ] [ text <| (String.left 2 <| String.fromFloat <| (cowDeathRate model.level * 100)) ++ "%" ]
                    ]
                , div [ css [ control ] ]
                    [ span [ css [ emojiTypography, emojiControl ] ] [ text <| "💵→🐄" ]
                    , btnMuted [ onClick <| BuyCows ] [ text <| String.fromInt (wholeCowsPlayerCanAfford model.money model.baseCowBuyPrice) ++ " cows" ]
                    ]
                , div [ css [ control ] ]
                    [ span [ css [ emojiTypography, emojiControl ] ] [ text <| "🐄→💵" ]
                    , btnMuted [ onClick <| SellCows ] [ text <| "$" ++ String.fromInt (cowSellPrice model.level * model.cows) ]
                    ]
                ]
            ]
        , div [ class "rules-zone", css [ color theme.muted ] ]
            [ h2 [ class "rules-heading" ] [ text <| "Rules" ]
            , ul []
                [ li [] [ text <| "🐮—Cow Herd." ]
                , li [] [ text <| "💰—Money." ]
                , li [] [ text <| "🌾—Hay Bales." ]
                , li [] [ text <| "🌽—Corn Fields." ]
                , li [] [ text <| "🚜—Tractors." ]
                , li [] [ text <| "💵—Sell your Herd." ]
                , li [] [ text <| "☠️—Herd Starves!" ]
                , li [] [ text <| "🐄—Buy a new Herd." ]
                , li [] [ text <| "Four tractors are automatically sold for $1" ]
                , li [] [ text <| "Base Cow Buy/Sell Price is $10 per Cow" ]
                , li [] [ text <| "Collect 10 cornfields to go up a level. Maximum level is " ++ String.fromInt maxLevel ++ "." ]
                , li [] [ text <| "Sell cows at towns with populations of at least 5,000—the price a cow will fetch increases with your level." ]
                , li [] [ text <| "Dead cornfields cause starvation—at higher levels, more cows will die each time." ]
                , li [] [ text <| "Buy a new herd at the market to exchange all your money for cows according to the price of a cow" ]
                ]
            ]
        ]
