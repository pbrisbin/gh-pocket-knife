--
-- TODO: once gh-pocket-knife is released, give this a stack shebang
--
{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import Data.Aeson
import GH
import LoadEnv

data Tag = Tag String String deriving Show

instance FromJSON Tag where
    parseJSON = withObject "Tag" $ \o -> Tag
        <$> o .: "name"
        <*> ((.: "sha") =<< o .: "commit")

main :: IO ()
main = do
    loadEnv -- reads GITHUB_ACCESS_TOKEN from .env

    tags <- getAll "/repos/pbrisbin/aurget/tags"

    mapM_ print (tags :: [Tag])
