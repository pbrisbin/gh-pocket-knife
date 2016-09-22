# The GitHub Pocket Knife

This library is meant to be useful in small, typically one-off CLI scripts. It
is not meant to be included in a larger library or application where any
reasonable level of robustness or comprehensiveness is desired.

As such, it has the following caveats:

- `"https://github.com"` is hard-coded within the library
- An access token must be provided as `$GITHUB_ACCESS_TOKEN`
- You provide your own resource types and JSON instances
- All API interactions are in `IO` and may raise exceptions
- The `Path` arguments are given to `parseUrlThrow` as-is, meaning you can append
  `?query=params` as you see fit. The addition of the `page` param for paginated
  `get` requests is naive, so a URL with a bare `?` will likely not work

## Usage

**./aurget-tags**

```hs
#!/usr/bin/env stack
{- stack
  --resolver lts-7.0
  --install-ghc
  runghc
  --package aeson
  --package gh-pocket-knife
-}
{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import Data.Aeson
import GH

-- Declare some data type you care about
newtype Tag = Tag { tagName :: String }

-- Describe how to parse it out of JSON responses
instance FromJSON Tag where
    parseJSON = withObject "Tag" $ \o -> Tag <$> o .: "name"

-- Call the GH API
main :: IO ()
main = getEach_ "/repos/pbrisbin/aurget/tags" $ putStrLn . tagName
```

Any system with `stack` installed should be able to take this file and run:

```console
% ./aurget-tags
v4.7.2
v4.7.1
v4.7.0
...
```

- [More examples](examples/)
- [Haddocks](http://hackage.haskell.org/package/gh-pocket-knife)

## CLI Wrapper

There's a small work-in-progress CLI wrapper included in the library. It's a
simple pass-through to the helper functions and outputs any returned JSON as-is:

```console
% export GITHUB_ACCESS_TOKEN=...
% gh-pocket-knife get /repos/pbrisbin/aurget/pulls/1 | jq "."
{
  "merged": false,
  "additions": 17,
  "state": "closed",
  "mergeable_state": "dirty",
  "review_comment_url": "https://api.github.com/repos/pbrisbin/aurget/pulls/comments{/number}",
  "mergeable": false,
  "assignees": [],
  "locked": false,
  ...
}
```
