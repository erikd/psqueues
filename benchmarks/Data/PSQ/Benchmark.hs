{-# LANGUAGE BangPatterns #-}

module Data.PSQ.Benchmark
    ( benchmark
    ) where

import           Data.List (foldl')
import           Data.PSQ
import           Criterion.Main
import           Prelude hiding (lookup)
import           BenchmarkTypes

benchmark :: (Int -> BElem) -> Int -> Benchmark
benchmark getElem benchmarkSize = bgroup "OrdPSQ"
    [ bench "minView" $ whnf prioritySum initialPSQ
    , bench "lookup" $ whnf (lookup' keys) initialPSQ
    , bench "insert (fresh)" $ whnf (insert' elems) empty
    , bench "insert (next fresh)" $ whnf (insert' secondElems) initialPSQ
    , bench "insert (duplicates)" $ whnf (insert' elems) initialPSQ
    -- , bench "insert (decreasing)" $ whnf (insert' elemsDecreasing) initialPSQ
    ]
  where
    (firstElems, secondElems) = splitAt (benchmarkSize `div` 2) elems
    elems = map getElem [0..benchmarkSize]
    keys = map (\(x,_,_) -> x) elems

    initialPSQ = fromList firstElems :: PSQ Int Int ()


lookup' :: [Int] -> PSQ Int Int () -> Int
lookup' xs m = foldl' (\n k -> maybe n fst (lookup k m)) 0 xs

insert' :: [BElem] -> PSQ Int Int () -> PSQ Int Int ()
insert' xs m0 = foldl' (\m (k, p, v) -> insert k p v m) m0 xs

prioritySum :: PSQ Int Int () -> Int
prioritySum = go 0
  where
    go !n t = case minView t of
      Nothing            -> n
      Just (k, x, _, t') -> go (n + k + x) t'
