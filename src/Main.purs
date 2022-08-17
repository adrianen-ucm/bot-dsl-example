module Main (main) where

import Prelude
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (Error, runAff_)
import Effect.Config (readConfig)
import Effect.Process (exit, printErrLn, readFile, args, printLn)
import Session.Parser (parse)
import Session.Runtime (eval)

main :: Effect Unit
main = do
  config <- readConfig >>= withErrorMessage "Error reading config file: "
  fileName <- parseArgs <$> args >>= withErrorMessage "Error parsing CLI args: "
  fileContents <- readFile fileName >>= withErrorMessage "Error reading session file: "
  session <- parse fileContents # withErrorMessage "Error parsing session file: "
  runAff_ handler $ eval config session

parseArgs :: Array String -> Either String String
parseArgs = case _ of
  [ fileName ] -> Right fileName
  _ -> Left "Expecting a single session file"

withErrorMessage :: forall a. String -> Either String a -> Effect a
withErrorMessage message = case _ of
  Right result -> pure result
  Left e -> do
    printErrLn failInitMessage
    printErrLn (message <> e)
    exit 1

handler :: forall a. Either Error a -> Effect Unit
handler = case _ of
  Right _ -> printLn successMessage
  Left e -> do
    printErrLn failMessage
    printErrLn (show e)
    exit 1

failInitMessage :: String
failInitMessage =
  """🤖 I couldn't start with the test session because of the following error:
"""

failMessage :: String
failMessage =
  """🤖 The following error happened during the test session:
"""

successMessage :: String
successMessage =
  """🤖 Every step seems ok from my side. Well done.
"""
