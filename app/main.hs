module Main (main) where

import Data.Aeson
import GH
import System.Environment (getArgs)

import Data.ByteString.Lazy.Char8 as C8

main :: IO ()
main = do
    args <- getArgs

    case args of
        ("get":path:_) -> display =<< get path
        ("get-all":path:_) -> displayAll =<< getAll path
        -- ("post":path:_)
        -- ("put":path:_)
        -- ("delete":path:_)
        _ -> errUsage

display :: Value -> IO ()
display = C8.putStrLn . encode

displayAll :: [Value] -> IO ()
displayAll = C8.putStrLn . encode

errUsage :: IO ()
errUsage = undefined
