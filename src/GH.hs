{-# LANGUAGE OverloadedStrings #-}
module GH
    ( get
    , getEach
    , getEach_
    , getAll
    , post
    , put
    , delete
    -- * lower level
    , module GH.Request
    ) where

import Control.Monad (void)
import Data.Aeson (FromJSON(..), ToJSON)
import Data.List (isInfixOf)
import Data.Monoid ((<>))

import GH.Request

get :: FromJSON a => Path -> IO a
get path = requestJSON path id

-- | Get a paginated resource, giving each item to the given action
--
-- Notes:
--
-- - This will yield each item out of each page, not each page of items.
-- - If you're trying to apply a pure function, instead use:
--
--   > map f <$> getAll path
--
getEach :: FromJSON a => Path -> (a -> IO b) -> IO [b]
getEach path f = go 1
  where
    go n = do
        page <- get $ appendPage n

        if null page
            then return []
            else (<>) <$> mapM f page <*> go (n + 1)

    -- Type this expression to avoid defaulted constraint warning
    appendPage :: Int -> String
    appendPage n
        | "?" `isInfixOf` path = path <> "&page=" <> show n
        | otherwise = path <> "?page=" <> show n

-- | @getEach@, but discarding the results of the provided action
getEach_ :: FromJSON a => Path -> (a -> IO b) -> IO ()
getEach_ path = void . getEach path

-- | @getEach@, but collecting all values into a list that is returned
getAll :: FromJSON a => Path -> IO [a]
getAll path = getEach path (return . id)

post :: (ToJSON a, FromJSON b) => Path -> a -> IO b
post path body = requestJSON path $ setMethod "POST" . setBody body

put :: (ToJSON a, FromJSON b) => Path -> a -> IO b
put path body = requestJSON path $ setMethod "POST" . setBody body

delete :: Path -> IO ()
delete path = requestJSON path $ setMethod "DELETE"
