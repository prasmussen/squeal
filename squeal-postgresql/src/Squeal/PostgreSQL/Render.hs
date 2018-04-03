{-|
Module: Squeal.PostgreSQL.Render
Description: Rendering helper functions
Copyright: (c) Eitan Chatav, 2017
Maintainer: eitan@morphism.tech
Stability: experimental

Rendering helper functions.
-}

{-# LANGUAGE
    ConstraintKinds
  , MagicHash
  , OverloadedStrings
  , PolyKinds
  , RankNTypes
  , ScopedTypeVariables
  , TypeApplications
#-}

module Squeal.PostgreSQL.Render
  ( -- * Render
    parenthesized
  , (<+>)
  , commaSeparated
  , renderCommaSeparated
  , renderCommaSeparatedMaybe
  , renderNat
  ) where

import Data.ByteString (ByteString)
import Data.Maybe
import Data.Monoid ((<>))
import Generics.SOP
import GHC.Exts
import GHC.TypeLits

import qualified Data.ByteString as ByteString

-- | Parenthesize a `ByteString`.
parenthesized :: ByteString -> ByteString
parenthesized str = "(" <> str <> ")"

-- | Concatenate two `ByteString`s with a space between.
(<+>) :: ByteString -> ByteString -> ByteString
str1 <+> str2 = str1 <> " " <> str2

-- | Comma separate a list of `ByteString`s.
commaSeparated :: [ByteString] -> ByteString
commaSeparated = ByteString.intercalate ", "

-- | Comma separate the renderings of a heterogeneous list.
renderCommaSeparated
  :: SListI xs
  => (forall x. expression x -> ByteString)
  -> NP expression xs -> ByteString
renderCommaSeparated render
  = commaSeparated
  . hcollapse
  . hmap (K . render)

-- | Comma separate the `Maybe` renderings of a heterogeneous list, dropping
-- `Nothing`s.
renderCommaSeparatedMaybe
  :: SListI xs
  => (forall x. expression x -> Maybe ByteString)
  -> NP expression xs -> ByteString
renderCommaSeparatedMaybe render
  = commaSeparated
  . catMaybes
  . hcollapse
  . hmap (K . render)

-- | Render a promoted `Nat`.
renderNat :: KnownNat n => proxy n -> ByteString
renderNat (_ :: proxy n) = fromString (show (natVal' (proxy# :: Proxy# n)))
