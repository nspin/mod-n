{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DeriveDataTypeable         #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE KindSignatures             #-}
{-# LANGUAGE MagicHash                  #-}
{-# LANGUAGE ScopedTypeVariables        #-}

---------------------------------------------------------
-- |
-- Module      : Numeric.Mod
-- Copyright   : (c) 2015 Nick Spinale
-- License     : MIT
--
-- Maintainer  : Nick Spinale <spinalen@carleton.edu>
-- Stability   : provisional
-- Portability : portable
--
-- Integers under a modulus
---------------------------------------------------------

module Numeric.Mod
    (
    -- * The 'Mod' newtype
      Mod
    ) where

import Control.Applicative
import Data.Bits
import Data.Data
import Data.Function
import Data.Ix
import Data.Proxy
import Data.Monoid
import Data.Traversable
import Data.Type.Equality
import GHC.Exts
import GHC.TypeLits
import Text.Printf

-- | Type representing an equivalence class under the integers mod n
newtype Mod (n :: Nat) = Mod { integer :: Integer }
    deriving (Eq, Ord, Real, Ix, PrintfArg, Data, Typeable)

-------------------------------
-- INSTANCES
-------------------------------

instance KnownNat n => Read (Mod n) where
    readsPrec = ((.).(.)) (map $ \(a, str) -> (fromInteger a, str)) readsPrec

instance Show (Mod n) where
    show = show . integer

instance KnownNat n => Bounded (Mod n) where
    minBound = 0
    maxBound = Mod (natVal' (proxy# :: Proxy# n) - 1)

instance KnownNat n => Enum (Mod n) where
    toEnum = Mod . toEnum
    fromEnum = fromEnum . integer

instance KnownNat n => Integral (Mod n) where
    toInteger = integer
    quotRem x y = case (quotRem `on` integer) x y of (q, r) -> (Mod q, Mod r)

instance KnownNat n => Num (Mod n) where
    fromInteger = Mod . flip mod (natVal' (proxy# :: Proxy# n))
    (+) = ((.).(.)) fromInteger ((+) `on` integer)
    (*) = ((.).(.)) fromInteger ((*) `on` integer)
    abs = id
    signum 0 = 0
    signum _ = 1
    negate = fromInteger . negate . toInteger