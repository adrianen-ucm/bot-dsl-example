module Session.Parser (parse) where

import Prelude
import Control.Alt ((<|>))
import Data.Either (Either)
import Data.Int (toNumber)
import Data.Newtype (wrap)
import Session.Class ((:>:))
import Session.Class as S
import Parsing.Session (Parser)
import Parsing.Session as P

-- Session parser
parse :: forall repr. S.Session repr => String -> Either String (repr S.AnonymousContext Unit)
parse = P.runParser anonymousSession

next :: forall s ctx. S.Session s => Parser (s ctx Unit) -> Parser (s ctx Unit)
next p = do
  whenM P.inSameLine $ P.fail "Unexpected item when expecting newline"
  whenM P.hasNested $ P.fail "Unexpected item, check the file indentation"
  P.hasNext >>= if _ then p else pure S.nothing

nested :: forall s ctx. S.Session s => Parser (s ctx Unit) -> Parser (s ctx Unit)
nested p = do
  whenM P.inSameLine $ P.fail "Unexpected item when expecting newline"
  P.hasNested >>= if _ then p else pure S.nothing

-- Anonymous session parser
data AnonymousIdentifier
  = Login
  | AnonymousDelay

anonymousSession :: forall s. S.Session s => Parser (s S.AnonymousContext Unit)
anonymousSession =
  P.reference $ identifier
    >>= case _ of
        Login -> do
          username <- P.stringArg
          password <- P.stringArg
          actions <- nested authSession
          following <- next anonymousSession
          pure $ S.login { username, password } actions :>: following
        AnonymousDelay -> do
          millis <- P.decimalArg
          following <- next anonymousSession
          pure $ S.delay (wrap (toNumber millis)) :>: following
  where
  identifier =
    (P.identifier "login" $> Login)
      <|> (P.identifier "delay" $> AnonymousDelay)

-- Auth session parser
data AuthAction
  = AuthDelay
  | RandomPost

authSession :: forall s. S.Session s => Parser (s S.AuthContext Unit)
authSession =
  P.reference $ identifier
    >>= case _ of
        RandomPost -> do
          actions <- nested documentSession
          following <- next authSession
          pure $ S.randomPost actions :>: following
        AuthDelay -> do
          millis <- P.decimalArg
          following <- next authSession
          pure $ S.delay (wrap (toNumber millis)) :>: following
  where
  identifier =
    (P.identifier "random_post" $> RandomPost)
      <|> (P.identifier "delay" $> AuthDelay)

-- Post session parser
data DocumentAction
  = PostReact
  | PostDelay
  | PostComment

documentSession :: forall s. S.Session s => Parser (s S.PostContext Unit)
documentSession =
  P.reference $ identifier
    >>= case _ of
        PostReact -> do
          r <- reaction
          following <- next documentSession
          pure $ S.reactToPost r :>: following
        PostDelay -> do
          millis <- P.decimalArg
          following <- next documentSession
          pure $ S.delay (wrap (toNumber millis)) :>: following
        PostComment -> do
          comment <- P.stringArg
          actions <- nested commentSession
          following <- next documentSession
          pure $ S.commentPost comment actions :>: following
  where
  identifier =
    (P.identifier "react" $> PostReact)
      <|> (P.identifier "delay" $> PostDelay)
      <|> (P.identifier "comment" $> PostComment)

-- Comment session parser
data CommentAction
  = CommentReact
  | CommentDelay
  | CommentEdit
  | CommentRemove
  | CommentReply

commentSession :: forall s. S.Session s => Parser (s S.CommentContext Unit)
commentSession =
  P.reference $ identifier
    >>= case _ of
        CommentReact -> do
          r <- reaction
          following <- next commentSession
          pure $ S.reactToComment r :>: following
        CommentDelay -> do
          millis <- P.decimalArg
          following <- next commentSession
          pure $ S.delay (wrap (toNumber millis)) :>: following
        CommentEdit -> do
          comment <- P.stringArg
          following <- next commentSession
          pure $ S.editComment comment :>: following
        CommentRemove -> do
          whenM P.hasNext $ P.fail "Cannot operate after remove"
          pure $ S.removeComment
        CommentReply -> do
          comment <- P.stringArg
          actions <- nested commentSession
          following <- next commentSession
          pure $ S.replyToComment comment actions :>: following
  where
  identifier =
    (P.identifier "react" $> CommentReact)
      <|> (P.identifier "delay" $> CommentDelay)
      <|> (P.identifier "edit" $> CommentEdit)
      <|> (P.identifier "remove" $> CommentRemove)
      <|> (P.identifier "reply" $> CommentReply)

-- Reaction parser
reaction :: Parser S.Reaction
reaction =
  (P.identifier "laugh" $> S.Laugh)
    <|> (P.identifier "smile" $> S.Smile)
    <|> (P.identifier "sad" $> S.Sad)
    <|> (P.identifier "angry" $> S.Angry)
