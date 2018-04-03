module Keccak where

open import Data.Nat
open import Data.Vec
open import Data.String as S
open import Data.Fin hiding (_+_)
open import Bits hiding (toℕ)
open import Extra renaming (
  roundLookup to get;
  roundLookup₂ to get₂;
  rotateRight to rot;
  generate to gen;
  generate₂ to gen₂;
  applyAt₂ to apply₂)

Word : Set
Word = Bits 64

Keccak-State : Set
Keccak-State = Vec (Vec Word 5) 5

Keccak-RC : Vec Word 24
Keccak-RC
  = fromString "1000000000000000000000000000000000000000000000000000000000000000"
  ∷ fromString "0100000100000001000000000000000000000000000000000000000000000000"
  ∷ fromString "0101000100000001000000000000000000000000000000000000000000000001"
  ∷ fromString "0000000000000001000000000000000100000000000000000000000000000001"
  ∷ fromString "1101000100000001000000000000000000000000000000000000000000000000"
  ∷ fromString "1000000000000000000000000000000100000000000000000000000000000000"
  ∷ fromString "1000000100000001000000000000000100000000000000000000000000000001"
  ∷ fromString "1001000000000001000000000000000000000000000000000000000000000001"
  ∷ fromString "0101000100000000000000000000000000000000000000000000000000000000"
  ∷ fromString "0001000100000000000000000000000000000000000000000000000000000000"
  ∷ fromString "1001000000000001000000000000000100000000000000000000000000000000"
  ∷ fromString "0101000000000000000000000000000100000000000000000000000000000000"
  ∷ fromString "1101000100000001000000000000000100000000000000000000000000000000"
  ∷ fromString "1101000100000000000000000000000000000000000000000000000000000001"
  ∷ fromString "1001000100000001000000000000000000000000000000000000000000000001"
  ∷ fromString "1100000000000001000000000000000000000000000000000000000000000001"
  ∷ fromString "0100000000000001000000000000000000000000000000000000000000000001"
  ∷ fromString "0000000100000000000000000000000000000000000000000000000000000001"
  ∷ fromString "0101000000000001000000000000000000000000000000000000000000000000"
  ∷ fromString "0101000000000000000000000000000100000000000000000000000000000001"
  ∷ fromString "1000000100000001000000000000000100000000000000000000000000000001"
  ∷ fromString "0000000100000001000000000000000000000000000000000000000000000001"
  ∷ fromString "1000000000000000000000000000000100000000000000000000000000000000"
  ∷ fromString "0001000000000001000000000000000100000000000000000000000000000001"
  ∷ []

Keccak-r : Vec (Vec ℕ 5) 5
Keccak-r
  = ( 0 ∷ 36 ∷  3 ∷ 41 ∷ 18 ∷ []) -- x = 0
  ∷ ( 1 ∷ 44 ∷ 10 ∷ 45 ∷  2 ∷ []) -- x = 1
  ∷ (62 ∷  6 ∷ 43 ∷ 15 ∷ 61 ∷ []) -- x = 2
  ∷ (28 ∷ 55 ∷ 25 ∷ 21 ∷ 56 ∷ []) -- x = 3
  ∷ (27 ∷ 20 ∷ 39 ∷  8 ∷ 14 ∷ []) -- x = 4
  ∷ []

Keccak-round : Word -> Keccak-State -> Keccak-State
Keccak-round RC A =
  let C  = map (foldr₁ xor) A
      D  = tabulate {n = 5} (λ x → xor (get (toℕ x + 4) C) (rot 1 (get (toℕ x + 1) C)))
      A₂ = imap₂ (\ y x v -> xor v (get x D)) A
      B  = gen₂ {w = 5} {h = 5} (\ y x -> rot (get₂ x ((y * 3) + x) Keccak-r) (get₂ x ((y * 3) + x) A₂))
      A₃ = imap₂ (\ y x v -> xor v (and (not (get₂ y (x + 1) B)) (get₂ y (x + 2) B))) B
      A₄ = apply₂ zero zero (\ x -> xor x RC) A₃
  in A₄

Keccak-f : Keccak-State -> Keccak-State
Keccak-f = icall 24 (λ i → Keccak-round (lookup i Keccak-RC))

ks : Keccak-State
ks
  = ( fromString "0110000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000" ∷ [])
  ∷ ( fromString "0000000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000001"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000" ∷ [])
  ∷ ( fromString "0000000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000" ∷ [])
  ∷ ( fromString "0000000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000" ∷ [])
  ∷ ( fromString "0000000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000"
    ∷ fromString "0000000000000000000000000000000000000000000000000000000000000000" ∷ []) ∷ []

ks₂ : Keccak-State
ks₂ = Keccak-f ks

v : Vec (Vec String 5) 5
v = imap₂ (λ y x v → toString v) ks₂