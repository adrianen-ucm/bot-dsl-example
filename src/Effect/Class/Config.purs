module Effect.Class.Config where

import Data.Either (Either)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Config as C

type Config
  = C.Config

readConfig :: forall m. MonadEffect m => m (Either String Config)
readConfig = liftEffect C.readConfig
