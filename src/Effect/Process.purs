module Effect.Process
  ( print
  , printLn
  , printErr
  , printErrLn
  , args
  , exit
  , readFile
  ) where

import Prelude
import Data.Either (Either(..))
import Effect (Effect)

foreign import readFileImpl ::
  (String -> Either String String) ->
  (String -> Either String String) ->
  String ->
  Effect (Either String String)

foreign import print :: String -> Effect Unit

foreign import printErr :: String -> Effect Unit

foreign import args :: Effect (Array String)

foreign import exit :: forall a. Int -> Effect a

readFile :: String -> Effect (Either String String)
readFile = readFileImpl Left Right

printLn :: String -> Effect Unit
printLn = print <<< (_ <> "\n")

printErrLn :: String -> Effect Unit
printErrLn = printErr <<< (_ <> "\n")
