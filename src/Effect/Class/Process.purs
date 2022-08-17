module Effect.Class.Process where

import Prelude
import Data.Either (Either)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Process as P

readFile :: forall m. MonadEffect m => String -> m (Either String String)
readFile = liftEffect <<< P.readFile

print :: forall m. MonadEffect m => String -> m Unit
print = liftEffect <<< P.print

printErr :: forall m. MonadEffect m => String -> m Unit
printErr = liftEffect <<< P.printErr

args :: forall m. MonadEffect m => m (Array String)
args = liftEffect P.args

exit :: forall m a. MonadEffect m => Int -> m a
exit = liftEffect <<< P.exit

printLn :: forall m. MonadEffect m => String -> m Unit
printLn = liftEffect <<< P.printLn

printErrLn :: forall m. MonadEffect m => String -> m Unit
printErrLn = liftEffect <<< P.printErrLn
