module Effect.Config
  ( Config
  , readConfig
  ) where

import Data.Either (Either(..))
import Effect (Effect)

type Config
  = { apiBaseUrl :: String }

foreign import readConfigImpl ::
  (String -> Either String String) ->
  (String -> Either String String) ->
  Effect (Either String Config)

readConfig :: Effect (Either String Config)
readConfig = readConfigImpl Left Right
