module Effect.Aff.Class.Runtime where

import Prelude
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Aff.Runtime as R
import Effect.Class.Config (Config)
import Session.Class as S

type Connection
  = R.Connection

connect :: forall m. MonadAff m => Config -> m Connection
connect = liftAff <<< R.connect

disconnect :: forall m. MonadAff m => Connection -> m Unit
disconnect = liftAff <<< R.disconnect

login :: forall m. MonadAff m => S.Credentials -> Connection -> m String
login ctx = liftAff <<< R.login ctx

randomPost :: forall m. MonadAff m => S.AuthContext -> Connection -> m Int
randomPost ctx = liftAff <<< R.randomPost ctx

reactToPost :: forall m. MonadAff m => S.Reaction -> S.PostContext -> Connection -> m Unit
reactToPost reaction ctx = liftAff <<< R.reactToPost reaction ctx

commentPost :: forall m. MonadAff m => String -> S.PostContext -> Connection -> m Int
commentPost comment ctx = liftAff <<< R.commentPost comment ctx

replyToComment :: forall m. MonadAff m => String -> S.CommentContext -> Connection -> m Int
replyToComment comment ctx = liftAff <<< R.replyToComment comment ctx

editComment :: forall m. MonadAff m => String -> S.CommentContext -> Connection -> m Unit
editComment comment ctx = liftAff <<< R.editComment comment ctx

removeComment :: forall m. MonadAff m => S.CommentContext -> Connection -> m Unit
removeComment ctx = liftAff <<< R.removeComment ctx

reactToComment :: forall m. MonadAff m => S.Reaction -> S.CommentContext -> Connection -> m Unit
reactToComment reaction ctx = liftAff <<< R.reactToComment reaction ctx
