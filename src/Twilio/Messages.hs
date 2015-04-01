{-#LANGUAGE MultiParamTypeClasses #-}
{-#LANGUAGE OverloadedStrings #-}

module Twilio.Messages
  ( -- * Resource
    Messages(..)
  , PostMessage(..)
  , Twilio.Messages.get
  , Twilio.Messages.post
  ) where

import Control.Applicative
import Data.Aeson
import qualified Data.Text as T
import Data.Text.Encoding
import Data.Maybe

import Control.Monad.Twilio
import Twilio.Internal.Request
import Twilio.Internal.Resource as Resource
import Twilio.Message
import Twilio.Types

{- Resource -}

data Messages = Messages
  { messagesPagingInformation :: PagingInformation
  , messageList :: [Message]
  } deriving (Show, Eq)

data PostMessage = PostMessage
  { sendTo   :: !String
  , sendFrom :: !String
  , sendBody :: !String
  } deriving (Show, Eq)

instance List Messages Message where
  getListWrapper = wrap (Messages . fromJust)
  getList = messageList
  getPlural = Const "messages"

instance FromJSON Messages where
  parseJSON = parseJSONToList

instance Get0 Messages where
  get0 = request (fromJust . parseJSONFromResponse) =<< makeTwilioRequest
    "/Messages.json"

instance Post1 PostMessage Message where
  post1 msg = request (fromJust . parseJSONFromResponse) =<<
    makeTwilioPOSTRequest "/Messages.json"
      [ ("To", encodeUtf8 . T.pack . sendTo $ msg)
      , ("From", encodeUtf8 . T.pack . sendFrom $ msg)
      , ("Body", encodeUtf8 . T.pack . sendBody $ msg)
      ]

-- | Get 'Messages'.
get :: Monad m => TwilioT m Messages
get = Resource.get

-- | Send a text message.
post :: Monad m => PostMessage -> TwilioT m Message
post = Resource.post