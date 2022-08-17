module Session.Runtime (Runtime, eval) where

import Prelude
import Control.Monad.Reader (ReaderT, withReaderT, runReaderT)
import Control.Monad.Reader.Class (class MonadAsk, ask, asks)
import Data.Newtype (unwrap, wrap)
import Effect.Aff (Aff, bracket, delay)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Aff.Class.Runtime as R
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Class.Config (Config)
import Effect.Class.Process (print, printLn)
import Record (merge)
import Session.Class as S

-- Runtime monad stack
type Env ctx
  = { conn :: R.Connection, ctx :: ctx, indent :: String }

newtype Runtime ctx a
  = Runtime (ReaderT (Env ctx) Aff a)

derive newtype instance functorRuntime :: Functor (Runtime ctx)

derive newtype instance applyRuntime :: Apply (Runtime ctx)

derive newtype instance applicativeRuntime :: Applicative (Runtime ctx)

derive newtype instance bindRuntime :: Bind (Runtime ctx)

derive newtype instance monadRuntime :: Monad (Runtime ctx)

derive newtype instance effRuntime :: MonadEffect (Runtime ctx)

derive newtype instance affRuntime :: MonadAff (Runtime ctx)

derive newtype instance askRuntime :: MonadAsk (Env ctx) (Runtime ctx)

runRuntime :: forall ctx a. Runtime ctx a -> ctx -> R.Connection -> Aff a
runRuntime (Runtime rt) ctx conn = runReaderT rt { conn, ctx, indent: "" }

withEnv :: forall c1 c2 a. (Env c2 -> Env c1) -> Runtime c1 a -> Runtime c2 a
withEnv f (Runtime rt) = Runtime $ withReaderT f rt

withContext :: forall c1 c2 a. Runtime c1 a -> c1 -> Runtime c2 a
withContext rt ctx = withEnv f rt
  where
  f { conn, indent } = { conn, ctx, indent }

withNestedContext :: forall c1 c2 a. Runtime c1 a -> c1 -> Runtime c2 a
withNestedContext rt ctx = withEnv f rt
  where
  f { conn, indent } = { conn, ctx, indent: indent <> "|  " }

report :: forall ctx a. String -> Runtime ctx a -> Runtime ctx a
report step rt = do
  { indent } <- ask
  liftEffect $ print $ indent <> step
  a <- rt
  liftEffect $ printLn ""
  pure a

reportResult :: forall ctx a. String -> (a -> String) -> Runtime ctx a -> Runtime ctx a
reportResult step f rt =
  report step
    $ do
        a <- rt
        liftEffect $ print $ " (" <> f a <> ")"
        pure a

-- Session runtime interpreter
eval :: forall a. Config -> Runtime S.AnonymousContext a -> Aff Unit
eval config rt =
  bracket
    (R.connect config)
    (R.disconnect >=> \_ -> printLn "")
    (runRuntime rt S.AnonymousContext >=> \_ -> pure unit)

instance sessionRuntime :: S.Session Runtime where
  chain rta rtb = rta >>= withContext rtb
  nothing = pure unit
  delay ms = do
    report step $ liftAff $ delay ms
    asks _.ctx
    where
    step = "Sleep " <> show (unwrap ms) <> " ms"
  login cred rt = do
    { conn, ctx } <- ask
    token <- report step $ R.login cred conn
    _ <- withNestedContext rt $ wrap { username, token }
    pure ctx
    where
    username = cred.username

    step = "Login with user " <> show username
  randomPost rt = do
    { conn, ctx } <- ask
    postId <- reportResult "Random post" f $ R.randomPost ctx conn
    _ <- withNestedContext rt $ wrap $ merge { postId } $ unwrap ctx
    pure ctx
    where
    f id = "id " <> show id
  reactToPost reaction = do
    { conn, ctx } <- ask
    _ <- report step $ R.reactToPost reaction ctx conn
    pure ctx
    where
    step = "reaction " <> show reaction
  commentPost comment rt = do
    { conn, ctx } <- ask
    commentId <- report step $ R.commentPost comment ctx conn
    _ <- withNestedContext rt $ wrap $ merge { commentId } $ unwrap ctx
    pure ctx
    where
    step = "Comment with " <> show comment
  replyToComment comment rt = do
    { conn, ctx } <- ask
    commentId <- report step $ R.replyToComment comment ctx conn
    _ <- withNestedContext rt $ wrap $ (unwrap ctx) { commentId = commentId }
    pure ctx
    where
    step = "Reply with " <> show comment
  editComment comment = do
    { conn, ctx } <- ask
    report step $ R.editComment comment ctx conn
    pure ctx
    where
    step = "Edit with " <> show comment
  removeComment = do
    { conn, ctx } <- ask
    report step $ R.removeComment ctx conn
    where
    step = "Remove"
  reactToComment reaction = do
    { conn, ctx } <- ask
    _ <- report step $ R.reactToComment reaction ctx conn
    pure ctx
    where
    step = "reaction " <> show reaction
