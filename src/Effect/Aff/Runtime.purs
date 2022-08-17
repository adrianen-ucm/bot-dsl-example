module Effect.Aff.Runtime
  ( Connection
  , connect
  , disconnect
  , login
  , randomPost
  , reactToPost
  , commentPost
  , replyToComment
  , editComment
  , removeComment
  , reactToComment
  ) where

import Prelude
import Control.Promise (Promise, toAffE)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class.Config (Config)
import Session.Class as S

foreign import data Connection :: Type

foreign import connectImpl :: Config -> Effect (Promise Connection)

foreign import disconnectImpl :: Connection -> Effect (Promise Unit)

foreign import loginImpl :: S.Credentials -> Connection -> Effect (Promise String)

foreign import randomPostImpl :: S.AuthContext -> Connection -> Effect (Promise Int)

foreign import reactToPostImpl :: S.Reaction -> (S.Reaction -> String) -> S.PostContext -> Connection -> Effect (Promise Unit)

foreign import commentPostImpl :: String -> S.PostContext -> Connection -> Effect (Promise Int)

foreign import replyToCommentImpl :: String -> S.CommentContext -> Connection -> Effect (Promise Int)

foreign import editCommentImpl :: String -> S.CommentContext -> Connection -> Effect (Promise Unit)

foreign import removeCommentImpl :: S.CommentContext -> Connection -> Effect (Promise Unit)

foreign import reactToCommentImpl :: S.Reaction -> (S.Reaction -> String) -> S.CommentContext -> Connection -> Effect (Promise Unit)

connect :: Config -> Aff Connection
connect = toAffE <<< connectImpl

disconnect :: Connection -> Aff Unit
disconnect = toAffE <<< disconnectImpl

login :: S.Credentials -> Connection -> Aff String
login credentials = toAffE <<< loginImpl credentials

randomPost :: S.AuthContext -> Connection -> Aff Int
randomPost ctx = toAffE <<< randomPostImpl ctx

reactToPost :: S.Reaction -> S.PostContext -> Connection -> Aff Unit
reactToPost reaction ctx = toAffE <<< reactToPostImpl reaction show ctx

commentPost :: String -> S.PostContext -> Connection -> Aff Int
commentPost comment ctx = toAffE <<< commentPostImpl comment ctx

replyToComment :: String -> S.CommentContext -> Connection -> Aff Int
replyToComment comment ctx = toAffE <<< replyToCommentImpl comment ctx

editComment :: String -> S.CommentContext -> Connection -> Aff Unit
editComment comment ctx = toAffE <<< editCommentImpl comment ctx

removeComment :: S.CommentContext -> Connection -> Aff Unit
removeComment ctx = toAffE <<< removeCommentImpl ctx

reactToComment :: S.Reaction -> S.CommentContext -> Connection -> Aff Unit
reactToComment reaction ctx = toAffE <<< reactToCommentImpl reaction show ctx
