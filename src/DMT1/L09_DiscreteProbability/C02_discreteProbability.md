```lean
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Data.Nat.Choose.Basic
import Mathlib.Tactic
```

# Discrete Probability (finite sample spaces)

This module introduces a minimal collection of definitions that are
sufficient for a first‑course treatment of discrete probability in Lean 4.
All sample spaces are assumed **finite** so that sums are finite and
measures are defined by explicit enumeration.

<!-- toc -->

## Overview

In probability theory, we work with:
1. **Sample spaces** (Ω): The set of all possible outcomes of an experiment
2. **Events** (A, B, ...): Subsets of the sample space
3. **Probability measures** (P): Functions that assign probabilities to events
4. **Random variables** (X, Y, ...): Functions from outcomes to values

This module implements these concepts for finite sample spaces, where we can
enumerate all outcomes and compute probabilities by summing over finite sets.
@@ -/

open Finset
open scoped BigOperators

namespace DMT1.L09_discreteProbability.discreteProbability

open Classical

```lean
## Basic Definitions

We start with the fundamental building blocks of probability theory.
```

```lean
    In probability, the sample space Ω represents all possible outcomes
    of a random experiment. For example:
    - Rolling a die: Ω = {1, 2, 3, 4, 5, 6}
    - Flipping a coin: Ω = {H, T}
    - Drawing a card: Ω = {all 52 cards}

    We use `Finset Ω` to ensure the space is finite, so we can
    enumerate all outcomes and compute finite sums. -/

    /-- A **sample space** is a finite set of outcomes. -/
abbrev SampleSpace (Ω : Type) := Finset Ω

/-- An **event** is a subset of the sample space.

    Events represent collections of outcomes we're interested in.
    For example, when rolling a die:
    - "Rolling even" = {2, 4, 6}
    - "Rolling less than 4" = {1, 2, 3}
    - "Rolling 6" = {6}

    Since events are subsets, we can combine them using set operations:
    intersection (∩), union (∪), complement, etc. -/
abbrev Event (Ω : Type) := Finset Ω

/-- A **probability measure** on a finite sample space.

    A probability measure assigns a real number P(ω) ≥ 0 to each outcome ω,
    such that the probabilities of all outcomes sum to 1.

    The four requirements (axioms) of probability are:
    1. `prob_nonneg`: All probabilities are non-negative: P(ω) ≥ 0
    2. `prob_support`: Outcomes outside the sample space have probability 0
    3. `prob_sum_one`: Probabilities of all outcomes sum to 1: Σ P(ω) = 1

    These axioms ensure that our probability function behaves as expected
    mathematically and matches our intuitive understanding of probability. -/
structure ProbabilityMeasure (Ω : Type) where
  space        : SampleSpace Ω      -- The finite set of all possible outcomes
  prob         : Ω → ℝ              -- Function assigning probability to each outcome
  prob_nonneg  : ∀ ω, 0 ≤ prob ω    -- Axiom 1: All probabilities are non-negative
  prob_support : ∀ ω, ω ∉ space → prob ω = 0  -- Axiom 2: No probability outside sample space
  prob_sum_one : space.sum prob = 1  -- Axiom 3: Total probability is 1

variable {Ω : Type} (μ : ProbabilityMeasure Ω)

/-- **Probability of an event** P(A).

    The probability of an event A is the sum of probabilities of all
    outcomes in A that are also in the sample space.

    Formula: P(A) = Σ_{ω ∈ A ∩ Ω} P(ω)

    We intersect with the sample space to handle cases where the event
    might contain outcomes not in our probability space (they contribute 0).

    Examples:
    - For a fair die, P({2, 4, 6}) = P(2) + P(4) + P(6) = 1/6 + 1/6 + 1/6 = 1/2
    - P(∅) = 0 (impossible event has probability 0)
    - P(Ω) = 1 (certain event has probability 1) -/
@[simp]
noncomputable def ProbabilityMeasure.P (A : Event Ω) : ℝ :=
  (A ∩ μ.space).sum μ.prob

/-!
## Basic Properties of Probability

These lemmas establish fundamental properties that every probability measure satisfies.
-/

/-- The **empty event** (impossible event) has probability 0.

    This makes intuitive sense: if no outcomes can occur, the probability is 0.

    Proof: The empty set intersected with anything is empty, and the sum
    over an empty set is 0. -/
@[simp] lemma P_empty : μ.P (∅ : Event Ω) = 0 := by
  -- Unfold the definition of P
  simp [ProbabilityMeasure.P]
  -- The intersection ∅ ∩ μ.space = ∅, and sum over empty set is 0

/-- The **entire sample space** (certain event) has probability 1.

    This follows directly from our axiom that all probabilities sum to 1.

    Proof: P(Ω) = (Ω ∩ Ω).sum μ.prob = Ω.sum μ.prob = 1 by prob_sum_one. -/
@[simp] lemma P_univ : μ.P μ.space = 1 := by
  -- Unfold P and use the fact that Ω ∩ Ω = Ω
  simp [ProbabilityMeasure.P, μ.prob_sum_one]

/-!
## Uniform Probability Measures

The uniform measure assigns equal probability to all outcomes.
This is the most common probability model in basic examples.
-/

/-- **Uniform probability measure** on a non‑empty finite set.

    In a uniform measure, every outcome has equal probability 1/|Ω|,
    where |Ω| is the number of outcomes in the sample space.

    This models "fair" random processes like:
    - Fair coin: P(H) = P(T) = 1/2
    - Fair die: P(1) = P(2) = ... = P(6) = 1/6
    - Random card: Each card has probability 1/52

    We require the sample space to be non-empty so that 1/|Ω| is well-defined. -/
noncomputable
def uniformMeasure {α : Type} (Ω : Finset α) (hΩ : Ω.Nonempty) :
    ProbabilityMeasure α := by
  -- We'll construct the measure step by step, verifying each axiom
  refine {
    space := Ω,
    prob := fun ω => if ω ∈ Ω then (1 : ℝ) / Ω.card else 0,
    prob_nonneg := ?_,
    prob_support := ?_,
    prob_sum_one := ?_ }

  -- Axiom 1: All probabilities are non-negative
  · intro ω
    by_cases hω : ω ∈ Ω
    · -- Case: ω ∈ Ω, so prob ω = 1/|Ω|
      -- Since Ω is non-empty, |Ω| > 0, so 1/|Ω| ≥ 0
      have hcard_pos : (0 : ℝ) < (Ω.card : ℝ) := by
        have : 0 < Ω.card := (Finset.card_pos).2 hΩ
        exact_mod_cast this
      have : (0 : ℝ) ≤ (1 : ℝ) / Ω.card :=
        div_nonneg (by norm_num) (le_of_lt hcard_pos)
      simpa [hω] using this
    · -- Case: ω ∉ Ω, so prob ω = 0 ≥ 0
      simp [hω]

  -- Axiom 2: Outcomes outside the sample space have probability 0
  · intro ω hω
    -- If ω ∉ Ω, then by definition prob ω = 0
    simp [hω]

  -- Axiom 3: Total probability is 1
  · -- We need to show that Σ_{ω ∈ Ω} (1/|Ω|) = 1
    have hcard_pos : 0 < Ω.card := (Finset.card_pos).2 hΩ
    have hcard_ne : (Ω.card : ℝ) ≠ 0 := by
      exact_mod_cast (Nat.ne_of_gt hcard_pos)

    -- Simplify the sum: for ω ∈ Ω, the indicator gives 1/|Ω|
    have hsum : (Ω.sum fun ω => if ω ∈ Ω then (1 : ℝ) / Ω.card else 0) =
        (Ω.sum fun _ => (1 : ℝ) / Ω.card) := by
      apply Finset.sum_congr rfl
      intro ω hω
      simp [hω]  -- Since ω ∈ Ω, the condition is true

    -- Sum of constant 1/|Ω| over |Ω| elements is |Ω| × (1/|Ω|) = 1
    have hsum_const : (Ω.sum fun _ => (1 : ℝ) / Ω.card) =
        (Ω.card : ℝ) * ((1 : ℝ) / Ω.card) := by
      simp [Finset.sum_const, Nat.cast_mul]

    -- |Ω| × (1/|Ω|) = 1 by basic algebra
    have hmul : (Ω.card : ℝ) * ((1 : ℝ) / Ω.card) = 1 := by
      field_simp [hcard_ne]

    -- Combine all steps
    simpa [hsum, hsum_const] using hmul

/-!
## Conditional Probability and Independence

These concepts help us understand how events relate to each other.
-/

/-- **Conditional probability** P(A | B) = P(A ∩ B) / P(B).

    This answers: "What's the probability of A happening, given that B happened?"

    Intuition: We restrict our attention to the outcomes where B occurs,
    then ask what fraction of those also have A occurring.

    Examples:
    - P(roll 6 | roll even) = P({6}) / P({2,4,6}) = (1/6) / (3/6) = 1/3
    - P(second card is ace | first card is ace) = 3/51 (3 aces left out of 51 cards)

    We require P(B) ≠ 0 to avoid division by zero. -/
noncomputable
def ProbabilityMeasure.condProb (A B : Event Ω) (hB : μ.P B ≠ 0) : ℝ :=
  μ.P (A ∩ B) / μ.P B

/-- **Independence of events**: A and B are independent if P(A ∩ B) = P(A) × P(B).

    Intuitively, A and B are independent if knowing that one occurred doesn't
    change the probability of the other occurring.

    Equivalent conditions (when P(B) > 0):
    - P(A ∩ B) = P(A) × P(B)  [definition]
    - P(A | B) = P(A)         [conditional probability equals unconditional]

    Examples:
    - Rolling two dice: getting 6 on first die is independent of getting 6 on second
    - Drawing with replacement: first card doesn't affect probability of second
    - Flipping coins: each flip is independent of previous flips -/
@[simp]
def ProbabilityMeasure.Independent (A B : Event Ω) : Prop :=
  μ.P (A ∩ B) = μ.P A * μ.P B

/-- **Bayes' rule**: P(A | B) = P(A ∩ B) / P(B).

    This is just the definition of conditional probability, but it's so fundamental
    it deserves its own name. Bayes' rule helps us "reverse" conditional probabilities:
    if we know P(B | A), we can find P(A | B).

    Full Bayes' rule: P(A | B) = P(B | A) × P(A) / P(B)

    This lemma establishes the basic form. The full version requires more setup. -/
lemma bayes {A B : Event Ω} (hB : μ.P B ≠ 0) :
    μ.condProb A B hB = μ.P (A ∩ B) / μ.P B := by
  -- This is literally the definition of conditional probability
  rfl

/-!
## Random Variables

Random variables are functions that assign numerical values to outcomes.
They let us work with numerical aspects of random experiments.
-/

/-- A **discrete random variable** with values in type `α`.

    A random variable X is a function that assigns a value X(ω) to each outcome ω.

    Examples:
    - Rolling a die: X(ω) = ω (identity function)
    - Sum of two dice: X(ω₁,ω₂) = ω₁ + ω₂
    - Number of heads in 3 coin flips: X counts the heads
    - Color of drawn card: X maps each card to its color

    The type `α` can be anything: numbers, strings, colors, etc. -/
abbrev DRandom (Ω α : Type) := Ω → α

/-- **Probability mass function** P(X = a) for a discrete random variable.

    This gives the probability that random variable X takes the specific value a.

    Formula: P(X = a) = Σ_{ω : X(ω) = a} P(ω)

    We sum the probabilities of all outcomes ω where X(ω) equals a.

    Examples:
    - For fair die X, P(X = 3) = 1/6
    - For sum of two dice, P(X = 7) = 6/36 = 1/6 (outcomes: (1,6), (2,5), (3,4), (4,3), (5,2), (6,1))
    - For number of heads in 2 flips, P(X = 1) = 2/4 = 1/2 (outcomes: HT, TH) -/
noncomputable
def ProbabilityMeasure.pmf {α} (X : DRandom Ω α) (a : α) : ℝ :=
  (μ.space.filter (fun ω => X ω = a)).sum μ.prob

/-- **Expectation** (expected value, mean) of a real-valued random variable.

    The expectation E[X] is the "average" value we expect X to take,
    weighted by the probabilities of different outcomes.

    Formula: E[X] = Σ_{ω ∈ Ω} P(ω) × X(ω)

    Intuition: If we repeated the experiment many times and averaged
    the values of X, we'd get approximately E[X].

    Examples:
    - Fair die: E[X] = (1×1/6) + (2×1/6) + ... + (6×1/6) = 21/6 = 3.5
    - Fair coin (H=1, T=0): E[X] = (1×1/2) + (0×1/2) = 1/2 = 0.5
    - Sum of two fair dice: E[X] = 7 -/
noncomputable
def ProbabilityMeasure.expectation (X : DRandom Ω ℝ) : ℝ :=
  μ.space.sum (fun ω => μ.prob ω * X ω)

/-- **Variance** Var(X) = E[(X - E[X])²] measures spread around the mean.

    Variance tells us how much X typically deviates from its expected value.
    - High variance: X values are spread out
    - Low variance: X values are clustered near E[X]

    Formula: Var(X) = E[(X - μ)²] where μ = E[X]

    The standard deviation σ = √Var(X) has the same units as X.

    Examples:
    - Constant random variable: Var(X) = 0 (no spread)
    - Fair coin (H=1, T=0): Var(X) = E[(X-0.5)²] = 0.25
    - Fair die: Var(X) ≈ 2.92 -/
noncomputable
def ProbabilityMeasure.variance (X : DRandom Ω ℝ) : ℝ :=
  let μX := μ.expectation X  -- μX is the mean of X
  μ.expectation (fun ω => (X ω - μX)^2)  -- E[(X - μ)²]

/-!
## Indicator Random Variables

Indicator variables are fundamental building blocks that connect events and random variables.
-/

/-- **Indicator function** of an event A.

    The indicator function 1_A(ω) equals 1 if ω ∈ A, and 0 otherwise.
    This converts an event (a set) into a random variable (a function).

    Uses:
    - Counting: If X counts successes, then X = 1_A₁ + 1_A₂ + ... + 1_Aₙ
    - Connecting events and expectations: E[1_A] = P(A)
    - Building complex random variables from simple events

    Examples:
    - 1_{even}(ω) = 1 if ω ∈ {2,4,6}, 0 otherwise (for rolling a die)
    - 1_{heads}(ω) = 1 if ω = H, 0 if ω = T (for coin flip) -/
@[simp]
noncomputable def indicator {Ω : Type} (A : Event Ω) : Ω → ℝ :=
  fun ω => if ω ∈ A then 1 else 0

/-- **Fundamental theorem**: E[1_A] = P(A).

    The expectation of an indicator random variable equals the probability of the event.

    This beautiful result connects the theory of random variables (expectation)
    with the theory of events (probability). It shows that probability is just
    a special case of expectation!

    Proof idea:
    - E[1_A] = Σ_{ω ∈ Ω} P(ω) × 1_A(ω)
    - = Σ_{ω ∈ A} P(ω) × 1 + Σ_{ω ∉ A} P(ω) × 0
    - = Σ_{ω ∈ A} P(ω)
    - = P(A)

    This theorem is the foundation for many advanced results in probability theory. -/
lemma expectation_indicator_eq_prob (A : Event Ω) :
    μ.expectation (indicator A) = μ.P A := by
  classical
  -- We'll show both sides equal the same sum: Σ_{ω ∈ A ∩ Ω} P(ω)

  -- Unfold all definitions to work with the basic sums
  unfold ProbabilityMeasure.expectation indicator ProbabilityMeasure.P

  -- The expectation becomes: Σ_{ω ∈ Ω} P(ω) × (if ω ∈ A then 1 else 0)
  -- Push the multiplication inside the conditional
  simp_rw [mul_ite, mul_one, mul_zero]
  -- Now we have: Σ_{ω ∈ Ω} (if ω ∈ A then P(ω) else 0)

  -- This sum equals the sum over the filtered set {ω ∈ Ω : ω ∈ A}
  have h_sum : μ.space.sum (fun ω => if ω ∈ A then μ.prob ω else 0) =
      (μ.space.filter (fun ω => ω ∈ A)).sum μ.prob := by
    -- Use the fundamental theorem about sums with conditionals
    rw [← Finset.sum_filter]

  -- The filtered set {ω ∈ Ω : ω ∈ A} is just A ∩ Ω
  have h_set : μ.space.filter (fun ω => ω ∈ A) = A ∩ μ.space := by
    ext ω  -- Show sets are equal by showing membership is equivalent
    simp [Finset.mem_filter, and_comm]  -- ω ∈ filter ↔ ω ∈ Ω ∧ ω ∈ A ↔ ω ∈ A ∩ Ω

  -- Combine everything: E[1_A] = sum over filtered set = sum over A ∩ Ω = P(A)
  rw [h_sum, h_set]

end DMT1.L09_discreteProbability.discreteProbability
```
