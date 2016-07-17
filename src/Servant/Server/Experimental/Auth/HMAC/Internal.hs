{-# LANGUAGE FlexibleContexts     #-}
{-# LANGUAGE TypeFamilies         #-}
{-# LANGUAGE DataKinds            #-}
{-# LANGUAGE GADTs                #-}
{-# LANGUAGE ScopedTypeVariables  #-}
{-# LANGUAGE KindSignatures       #-}
{-# LANGUAGE OverloadedStrings    #-}

{-|
  Module:      Servant.Server.Experimental.Auth.Cookie.Internal
  Copyright:   (c) 2016 Al Zohali
  License:     GPL3
  Maintainer:  Al Zohali <zohl@fmap.me>
  Stability:   experimental


  = Description
  Internals of `Servant.Server.Experimental.Auth.Cookie`.
-}

module Servant.Server.Experimental.Auth.HMAC.Internal where


import Control.Monad.IO.Class
import Data.Serialize            (Serialize, put, get)
import Network.Wai               (Request, requestHeaders)

import qualified Data.ByteArray as BA
import qualified Data.ByteString as BS            (length, splitAt, concat, pack)
import qualified Data.ByteString.Base64 as Base64 (encode, decode)
import qualified Data.ByteString.Char8 as BS8

import Data.ByteString              (ByteString)
import Data.ByteString.Lazy         (toStrict, fromStrict)
import Data.ByteString.Lazy.Builder (toLazyByteString)

import GHC.TypeLits (Symbol)

import Servant                          (throwError)
import Servant                          (addHeader, Proxy(..))
import Servant.API.Experimental.Auth    (AuthProtect)
import Servant.API.ResponseHeaders      (AddHeader)
import Servant.Server                   (err403, errBody, Handler)
import Servant.Server.Experimental.Auth (AuthHandler, AuthServerData, mkAuthHandler)



-- | A type family that maps user-defined account type to
--   AuthServerData. This should be instantiated as the following:
-- @
--   type instance AuthHmacAccount = UserDefinedType
-- @
type family AuthHmacAccount

-- | A type family that maps user-defined session type to
--   AuthServerData. This should be instantiated as the following:
-- @
--   type instance AuthHmacSession = UserDefinedType
-- @
type family AuthHmacSession

type AuthHmacData = (AuthHmacAccount, AuthHmacSession)
type instance AuthServerData (AuthProtect "hmac-auth") = AuthHmacData



-- | Options that determine authentication mechanisms.
data Settings where
  Settings :: {
    getSession :: AuthHmacAccount -> IO (Maybe AuthHmacSession)
  } -> Settings


-- | TODO
defaultSettings :: Settings
defaultSettings = Settings {
    getSession = undefined
  }


-- | HMAC handler
defaultAuthHandler :: Settings -> AuthHandler Request AuthHmacData
defaultAuthHandler settings = mkAuthHandler handler where

  handler :: Request -> Handler AuthHmacData
  handler req = do
    let account = undefined
    session <- liftIO $ (getSession settings) account
    return (account, maybe undefined id session)
