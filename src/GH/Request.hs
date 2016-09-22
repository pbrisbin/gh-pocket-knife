{-# LANGUAGE OverloadedStrings #-}
module GH.Request
    ( Path
    , requestJSON
    , setMethod
    , setBody
    ) where

import Control.Monad.Trans.Resource
import Data.Aeson (FromJSON(..), ToJSON(..), eitherDecode, encode)
import Data.ByteString (ByteString)
import Data.Monoid ((<>))
import Network.HTTP.Conduit hiding (path)
import System.Environment (getEnv)

import qualified Data.ByteString.Char8 as C8

type Path = String

requestJSON :: FromJSON a => Path -> (Request -> Request) -> IO a
requestJSON path modify = do
    t <- getEnv "GITHUB_ACCESS_TOKEN"
    r <- setHeaders t . modify
        <$> parseUrlThrow ("https://api.github.com" <> path)
    m <- newManager tlsManagerSettings
    bs <- runResourceT $ responseBody <$> httpLbs r m
    return $ either error id $ eitherDecode bs

setMethod :: ByteString -> Request -> Request
setMethod m r = r { method = m }

setBody :: ToJSON a => a -> Request -> Request
setBody b r = r { requestBody = RequestBodyLBS $ encode b }

setHeaders :: String -> Request -> Request
setHeaders token r = r
    { requestHeaders =
        [ ("Accept", "application/json")
        , ("Authorization", "token " <> C8.pack token)
        , ("Content-Type", "application/json")
        , ("User-Agent", "gh-pocket-knife")
        ]
    }
