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

- [Examples](examples/)
- [Haddocks](http://hackage.haskell.org/package/gh-pocket-knife)
