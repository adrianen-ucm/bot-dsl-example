module Parsing.Session
  ( Parser
  , runParser
  , fail
  , reference
  , identifier
  , stringArg
  , decimalArg
  , whiteSpace
  , inSameLine
  , hasNested
  , hasNext
  ) where

import Prelude
import Control.Alt ((<|>))
import Data.Bifunctor (lmap)
import Data.Either (Either)
import Data.Newtype (unwrap)
import Parsing as P
import Parsing.Indent as I
import Parsing.Combinators (try)
import Parsing.Language (haskellStyle)
import Parsing.String (eof)
import Parsing.Token (TokenParser, makeTokenParser)

type Parser a
  = I.IndentParser String a

hoist :: forall a. P.Parser String a -> Parser a
hoist = P.hoistParserT (unwrap >>> pure)

runParser :: forall a. Parser a -> String -> Either String a
runParser parser string =
  lmap handler
    $ I.runIndent
    $ P.runParserT string
    $ (whiteSpace *> parser <* eof)
  where
  handler e =
    let
      P.Position { column, line } = P.parseErrorPosition e
    in
      P.parseErrorMessage e
        <> " at line "
        <> show line
        <> ", column "
        <> show column
        <> "."

fail :: forall a. String -> Parser a
fail = P.fail

reference :: forall a. Parser a -> Parser a
reference = I.withPos

arg :: forall a. Parser a -> Parser a
arg p = inSameLine >>= if _ then p else P.fail message
  where
  message = "Arguments should be passed within the same line"

tokenParser :: TokenParser
tokenParser = makeTokenParser haskellStyle

identifier :: String -> Parser Unit
identifier i = try (hoist $ tokenParser.symbol i) $> unit

stringArg :: Parser String
stringArg = arg $ hoist tokenParser.stringLiteral

decimalArg :: Parser Int
decimalArg = arg $ hoist $ tokenParser.lexeme tokenParser.decimal

whiteSpace :: Parser Unit
whiteSpace = hoist tokenParser.whiteSpace

inSameLine :: Parser Boolean
inSameLine =
  (eof $> false)
    <|> (I.sameLine $> true)
    <|> pure false

hasNext :: Parser Boolean
hasNext =
  (eof $> false)
    <|> try (I.checkIndent $> true)
    <|> pure false

hasNested :: Parser Boolean
hasNested =
  (eof $> false)
    <|> try (I.indented' $> true)
    <|> pure false
