{-# LANGUAGE DeriveAnyClass             #-}
{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE DuplicateRecordFields      #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module UniswapJsonApi.Types
  where

import Control.DeepSeq
import Control.Monad.Except     (ExceptT, MonadError)
import Control.Monad.Reader     (MonadIO, MonadReader, ReaderT)
import Data.Aeson               (FromJSON, ToJSON, Value)
import Data.ByteString          (ByteString)
import Data.List                (find)
import Data.Text                (Text)
import Data.UUID                (UUID)
import GHC.Generics
import Network.Wai.Handler.Warp (HostPreference)
import Servant                  (ServerError)

type Instance = Text

type HistoryId = Text

data History a = History [(HistoryId, a)] [HistoryId]
  deriving (Show, Generic, FromJSON, ToJSON)

lookupHistory :: HistoryId -> History a -> Maybe a
lookupHistory hid (History hs _) = snd <$> find (\h' -> hid == fst h') (reverse hs)

data UniswapStatusResponse = UniswapStatusResponse
  { cicCurrentState :: UniswapCurrentState,
    cicContract     :: UniswapContract,
    cicWallet       :: UniswapWallet,
    cicDefintion    :: UniswapDefinition
  }
  deriving (Generic, Show, FromJSON, ToJSON)

instance NFData UniswapStatusResponse where rnf = rwhnf
data UniswapHook = UniswapHook
  { rqID      :: Integer,
    itID      :: Integer,
    rqRequest :: Value
  }
  deriving (Show, Generic, FromJSON, ToJSON)

data UniswapCurrentState = UniswapCurrentState
  { observableState :: History UniswapMethodResult,
    hooks           :: [UniswapHook],
    err             :: Maybe Text,
    logs            :: [UniswapLog],
    lastLogs        :: [UniswapLog]
  }
  deriving (Show, Generic, FromJSON, ToJSON)

data UniswapLog = UniswapLog
  { _logMessageContent :: Text,
    _logLevel          :: Text
  } deriving (Show, Generic, FromJSON, ToJSON)


data UniswapDefinition = UniswapDefiniotion
  { contents :: Value,
    tag      :: Text

  } deriving (Show, Generic, FromJSON, ToJSON)

-- | add ADT to handle all possible types in Result
type UniswapMethodResult = Either Text UniswapSuccessMethodResult


data UniswapSuccessMethodResult = UniswapSuccessMethodResult
  { contents :: Maybe Value,
    tag      :: Text
  }
  deriving (Show, Generic, FromJSON, ToJSON)

newtype UniswapContract = UniswapContract
  { unContractInstanceId :: Text
  }
  deriving (Show, Generic, FromJSON, ToJSON)

newtype UniswapWallet = UniswapWallet
  { getWallet :: Integer
  }
  deriving (Show, Generic, FromJSON, ToJSON)


data PabConfig = MkPabConfig
  { pabUrl  :: String
  , pabPort :: Int
  } deriving Show

data AppContext = MkAppContext
  { pab  :: PabConfig
  , port :: Int
  } deriving (Show)


