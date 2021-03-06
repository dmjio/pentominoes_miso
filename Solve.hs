module Solve ( steps, solutions, Progress(..) ) where

import Control.Monad
import Data.Set as DS 
import Data.Tree

data Progress a = Progress { used :: [Set a]
                           , uncovered :: Set a
                           , unused :: Set (Set a)
                           } 

next :: Ord a => Progress a -> [Progress a]
next (Progress used uncovered unused) = do
  guard (not $  DS.null uncovered) -- no uncovered space left; solved

  -- find the spot with the least number of unused pieces containing it.
  let coverageCounts = DS.map (\loc -> (length $ DS.filter (member loc) unused, loc)) uncovered
      (minCount, minCountElement) = findMin coverageCounts

  guard (minCount > 0) -- nothing goes here; failed

  -- get each unused piece that covers this spot
  ns <- toList $ DS.filter (member $ minCountElement) unused

  let -- remove the spots covered by this piece from the board
      newUncovered = uncovered \\ ns

      -- remove the unused pieces that share a spot with this piece
      newUnused = DS.filter (DS.null . intersection ns) unused

      -- add the piece to the solution being built up.
      newUsed = ns : used

  return $ Progress newUsed newUncovered newUnused

steps :: Ord a => Progress a -> [Progress a]
steps initial = 
  flatten $ unfoldTree (\p -> (p, next p)) initial

solutions :: Ord a => Progress a -> [Progress a]
solutions initial = 
  Prelude.filter (DS.null . uncovered ) $ steps initial

