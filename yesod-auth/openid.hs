{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
import Yesod.Core
import Yesod.Auth
import Yesod.Auth.OpenId
import Data.Text (Text)
import Text.Hamlet (hamlet)
import Control.Monad.IO.Class (liftIO)
import Yesod.Form
import Network.Wai.Handler.Warp (run)

data BID = BID

mkYesod "BID" [parseRoutes|
/ RootR GET
/after AfterLoginR GET
/auth AuthR Auth getAuth
|]

getRootR :: Handler RepHtml
getRootR = getAfterLoginR

getAfterLoginR :: Handler RepHtml
getAfterLoginR = do
    mauth <- maybeAuthId
    defaultLayout $ addHamlet [hamlet|
<p>Auth: #{show mauth}
$maybe _ <- mauth
    <p>
        <a href=@{AuthR LogoutR}>Logout
$nothing
    <p>
        <a href=@{AuthR LoginR}>Login
|]

instance Yesod BID where
    approot _ = "http://localhost:3000"

instance YesodAuth BID where
    type AuthId BID = Text
    loginDest _ = AfterLoginR
    logoutDest _ = AuthR LoginR
    getAuthId = return . Just . credsIdent
    authPlugins = [authOpenId]

instance RenderMessage BID FormMessage where
    renderMessage _ _ = defaultFormMessage

main :: IO ()
main = toWaiApp BID >>= run 3000

