/- @@@
# Negation (¬)

## Big Idea from Last Time

- one pigeon is no holes is impossible (pigeonhole principle)
- (P → Empty), (P → False) uninhabited unless P is uninhabited
- So if (P → Empty), (P → False), then P must be uninhabited
- In Type uninhabited means empty. In Prop is means false.
- Empty : Type and False : Prop are given uninhabited types

## New Idea: Not (¬)

- Suppose α and P are uninhabited types / propositions
  - { α : Type } (pEmpty : α → Empty)
  - { P : Prop } (pFalse : P → Prop)
@@@ -/

namespace Alpha.book1lib.chapters.C09_negation

axiom α : Type
axiom P : Prop

/- @@@
### Optional Side-Note

- Type is Type 0 is Sort 1
- Prop is Sort 0

You can generalize with `Sort u`

### Negation Introduction

#### Logical case
  - Knowing that P is uninhabited
  - Means knowing there is no proof of it
  - Means knowing for sure that it's false
  - Now we'd like to say *Not p* is true
  - A perfect proof: *pFalse : P → False*
  - We *define* *(Not P)* to be *P → False*
@@@ -/

#check (Not)      -- Not (a : Prop) : Prop
-- def Not (a : Prop) : Prop := a → False

/- @@@
Just as *∧ : Prop → Prop → Prop* is notation
for *And _ _*, mathematics and logic use the
unary prefix notation, ¬P, to mean (Not P),
which, in turn, means *P → False*. These are
all the same proposition.
@@@ -/

#reduce (types := true) ¬P
#reduce (types := true) Not P
-- P → False

/- @@@
We cannot overemphasize the importance of very
quickly learning to translate between *¬P* and
*P → False* as meaning exactly the same thing.
In particular, a proof of *¬P* is a *function*
(of type P → False).

What does this mean? Suppose you have your own
uninhabited logical type (proposition), *Wrong,*
with no proofs. What interesting new proposition
should we be able to prove about *Wrong*?
@@@ -/

-- EXERCISE: Define an uninhabited proposition Wrong, then prove ¬Wrong

/- @@@
### Key Functions Involving Negation
@@@ -/

def foo {P : Prop} {α : Type}: (P → False) → P → α :=
(
  fun pf =>
  (
    fun (p : P) => nomatch (pf p)
  )
)

def bar {P : Prop} {α : Type} : ¬P → P → α
| np, p => nomatch (np p)

def noContra {P : Prop} : ¬ (P ∧ ¬ P)
| h => nomatch h
-- (
--   let p := h.left
--   let np := h.right
--   _
-- )

-- NOTE: The following is NOT provable in constructive logic!
-- It requires classical logic (excluded middle).
-- theorem porqValid {P : Prop} : P ∨ ¬P := ???

/- @@@
## Exercises

### Exercise #1: DeMorgan (one direction)

Is this variant of one of DeMorgan's logically valid (provable)?
Note: This direction requires classical logic and cannot be
proven constructively. The underscore shows where we get stuck.
@@@ -/

-- CHALLENGE: Try to complete this proof. You will get stuck!
-- This demonstrates a limit of constructive logic.
-- Uncomment the following definition to see Lean's error showing the stuck proof state:
/-
theorem notDistribOverAnd {P Q : Prop} : ¬(P ∧ Q) → (¬P ∨ ¬Q)
| h  =>     -- assume: ¬(P ∧ Q), (P ∧ Q) → False; show (¬P ∨ ¬Q)
  (Or.inl
    (fun (p : P) =>
      (
        _  -- STUCK: We cannot derive False from just p and h
      )
    )
  )
@@@ -/

/- @@@
### Exercise #2: DeMorgan (other direction)

Assume proof of condition, (h : (¬P ∨ ¬Q)), show ¬(P ∧ Q).
The premise is a disjunction, use Or.elim giving two cases:
  - ¬P → ¬(P ∧ Q)
  - ¬Q → ¬(P ∧ Q)

In the first case with (np : ¬P), show ¬(P ∧ Q)

- ¬(P ∧ Q) just means (P ∧ Q) → False
- to prove ¬(P ∧ Q) is to prove (P ∧ Q) → False
- so assume (h : P ∧ Q). Take it from there!

In the second case with (nq : ¬Q), show ¬(P ∧ Q),
well, you know what to do!
@@@ -/

-- EXERCISE: Complete this proof
theorem notDistribOverAnd' {P Q : Prop} :  (¬P ∨ ¬Q) → ¬(P ∧ Q) :=
fun h => match h with
  | (Or.inl np)  => -- assume ¬P
    (
      fun pq =>   -- to prove ¬(P ∧ Q), assume it; then what?
      (
        sorry  -- EXERCISE: Use np and pq to derive False
      )
    )
  | (Or.inr nq) => sorry  -- EXERCISE: Similar reasoning with nq

/- @@@
### Exercise #3: DeMorgan for Or

Formally state and prove the following proposition
in Lean, if such proofs exist. Use the preceding
statements and proof constructions as models should
you need to resolve any issues of mere Lean syntax.
The English-language statement is that negation over
disjunction is conjunction of negations. Remember:
to prove ↔ you must have proofs of both the ← and →
implications. You might start top down by applying
the final Iff.intro _ _ to the two sub-proofs you'll
need, leaving them as ( _ ), properly indented on
their own lines. Then fill in the remaining proofs
as required.
@@@ -/

-- EXERCISE: State and prove this theorem
-- theorem deMorganOr {P Q : Prop} : ¬(P ∨ Q) ↔ (¬P ∧ ¬Q) := sorry

/- @@@
## Summary

### Key Definition

**Not P** is defined as **P → False**
@@@ -/

/- @@@
```
def Not (P : Prop) : Prop := P → False
```
@@@ -/

/- @@@
Notation: `¬P` means `Not P` means `P → False`

### Inference Rules

**Negation Introduction (¬-intro):**

To prove ¬P, prove P → False. That is, assume P and derive a contradiction.
@@@ -/

/- @@@
```
   Γ, p : P ⊢ f : False
---------------------------- ¬-intro
    Γ ⊢ (fun p => f) : ¬P
```
@@@ -/

/- @@@
**Negation Elimination (¬-elim):**

From ¬P and P, derive False (contradiction).
@@@ -/

/- @@@
```
  Γ ⊢ np : ¬P    Γ ⊢ p : P
------------------------------ ¬-elim
      Γ ⊢ (np p) : False
```
@@@ -/

/- @@@
Then use False.elim to derive any proposition.

### Key Theorems

| Theorem | Statement | Provable? |
|---------|-----------|-----------|
| No contradiction | `¬(P ∧ ¬P)` | ✓ Constructive |
| DeMorgan And→Or | `¬(P ∧ Q) → (¬P ∨ ¬Q)` | ✗ Requires classical |
| DeMorgan Or→And | `(¬P ∨ ¬Q) → ¬(P ∧ Q)` | ✓ Constructive |
| DeMorgan Or↔And | `¬(P ∨ Q) ↔ (¬P ∧ ¬Q)` | ✓ Constructive |

### Curry-Howard Connection

| Logic | Computation |
|-------|-------------|
| ¬P | P → Empty |
| Proof of ¬P | Function showing P is uninhabited |

### Looking Ahead (Book II)

Some negation-related principles require **classical logic**
(the law of excluded middle), including:

- `P ∨ ¬P` (law of excluded middle)
- `¬¬P → P` (double negation elimination)
- `¬(P ∧ Q) → (¬P ∨ ¬Q)` (one direction of DeMorgan)

These are **not provable** in constructive logic! We will
explore classical reasoning in Book II.
@@@ -/

end Alpha.book1lib.chapters.C09_negation
