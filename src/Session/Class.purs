module Session.Class where

import Data.Newtype (class Newtype)
import Data.Time.Duration (Milliseconds)
import Prelude

-- Context
type AuthRow
  = ( username :: String, token :: String )

type PostRow
  = ( postId :: Int | AuthRow )

type CommentRow
  = ( commentId :: Int | PostRow )

data AnonymousContext
  = AnonymousContext

newtype AuthContext
  = AuthContext (Record AuthRow)

newtype PostContext
  = PostContext (Record PostRow)

newtype CommentContext
  = CommentContext (Record CommentRow)

instance Newtype AuthContext (Record AuthRow)

instance Newtype PostContext (Record PostRow)

instance Newtype CommentContext (Record CommentRow)

-- Session tagless final encoding
data Reaction
  = Laugh
  | Smile
  | Sad
  | Angry

instance showReaction :: Show Reaction where 
  show Laugh = "laugh"
  show Smile = "smile"
  show Sad = "sad"
  show Angry = "angry"

type Credentials 
  = { username :: String, password :: String}

type Embed :: (Type -> Type -> Type) -> Type -> Type -> Type
type Embed repr embed into
  = forall a. repr embed a -> repr into into

class Session repr where
  chain :: forall a b c. repr a b -> repr b c -> repr a c
  nothing :: forall a. repr a Unit
  delay :: forall a. Milliseconds -> repr a a
  login :: Credentials -> Embed repr AuthContext AnonymousContext
  randomPost :: Embed repr PostContext AuthContext
  reactToPost :: Reaction -> repr PostContext PostContext
  commentPost :: String -> Embed repr CommentContext PostContext
  replyToComment :: String -> Embed repr CommentContext CommentContext
  editComment :: String -> repr CommentContext CommentContext
  removeComment :: repr CommentContext Unit
  reactToComment :: Reaction -> repr CommentContext CommentContext

infixl 1 chain as :>:
