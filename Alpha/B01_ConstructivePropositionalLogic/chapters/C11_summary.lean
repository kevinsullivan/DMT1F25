/- @@@
# Book I Summary and Review

This chapter provides a comprehensive reference for all the inference
rules covered in Book I, followed by exercises that combine multiple
connectives, and a preview of Book II.

<!-- toc -->

## Complete Inference Rules Reference

### True

**Introduction:**
@@@ -/

/- @@@
```
------------------- True.intro
  Γ ⊢ True.intro : True
```
@@@ -/

/- @@@
**Elimination:** None (True carries no information)

### And (∧)

**Introduction:**
@@@ -/

/- @@@
```
  Γ ⊢ p : P      Γ ⊢ q : Q
----------------------------- And.intro
  Γ ⊢ And.intro p q : P ∧ Q
```
@@@ -/

/- @@@
Alternative notation: `⟨p, q⟩`

**Elimination (left):**
@@@ -/

/- @@@
```
    Γ ⊢ h : P ∧ Q
--------------------- And.left
    Γ ⊢ h.left : P
```
@@@ -/

/- @@@
**Elimination (right):**
@@@ -/

/- @@@
```
    Γ ⊢ h : P ∧ Q
---------------------- And.right
    Γ ⊢ h.right : Q
```
@@@ -/

/- @@@
### Implies (→)

**Introduction:**
@@@ -/

/- @@@
```
    Γ, p : P ⊢ q : Q
--------------------------- →-intro
  Γ ⊢ (fun p => q) : P → Q
```
@@@ -/

/- @@@
**Elimination (Modus Ponens):**
@@@ -/

/- @@@
```
  Γ ⊢ f : P → Q      Γ ⊢ p : P
--------------------------------- →-elim
        Γ ⊢ f p : Q
```
@@@ -/

/- @@@
### Iff (↔)

**Introduction:**
@@@ -/

/- @@@
```
  Γ ⊢ f : P → Q      Γ ⊢ g : Q → P
------------------------------------- Iff.intro
      Γ ⊢ Iff.intro f g : P ↔ Q
```
@@@ -/

/- @@@
Alternative notation: `⟨f, g⟩`

**Elimination (forward):**
@@@ -/

/- @@@
```
    Γ ⊢ h : P ↔ Q
---------------------- Iff.mp
  Γ ⊢ h.mp : P → Q
```
@@@ -/

/- @@@
**Elimination (backward):**
@@@ -/

/- @@@
```
    Γ ⊢ h : P ↔ Q
---------------------- Iff.mpr
  Γ ⊢ h.mpr : Q → P
```
@@@ -/

/- @@@
### Or (∨)

**Introduction (left):**
@@@ -/

/- @@@
```
      Γ ⊢ p : P
------------------------ Or.inl
  Γ ⊢ Or.inl p : P ∨ Q
```
@@@ -/

/- @@@
**Introduction (right):**
@@@ -/

/- @@@
```
      Γ ⊢ q : Q
------------------------ Or.inr
  Γ ⊢ Or.inr q : P ∨ Q
```
@@@ -/

/- @@@
**Elimination (case analysis):**
@@@ -/

/- @@@
```
  Γ ⊢ h : P ∨ Q    Γ ⊢ f : P → R    Γ ⊢ g : Q → R
--------------------------------------------------- Or.elim
              Γ ⊢ Or.elim h f g : R
```
@@@ -/

/- @@@
Or using match:
@@@ -/

-- TODO: Fix
-- match h with
-- | Or.inl p => ... -- use p : P to produce R
-- | Or.inr q => ... -- use q : Q to produce R

/- @@@
### False

**Introduction:** None (False has no proofs)

**Elimination:**
@@@ -/

/- @@@
```
      Γ ⊢ f : False
------------------------ False.elim
  Γ ⊢ False.elim f : P
```
@@@ -/

/- @@@
For any proposition P. Also written `nomatch f`.

### Negation (¬)

Recall: `¬P` is *defined* as `P → False`

**Introduction:**
@@@ -/

/- @@@
```
    Γ, p : P ⊢ f : False
---------------------------- ¬-intro
  Γ ⊢ (fun p => f) : ¬P
```
@@@ -/

/- @@@
**Elimination:**
@@@ -/

/- @@@
```
  Γ ⊢ np : ¬P      Γ ⊢ p : P
------------------------------- ¬-elim
        Γ ⊢ np p : False
```
@@@ -/

/- @@@
Then use False.elim to derive anything.

## Curry-Howard Summary

| Logic (Prop) | Computation (Type) |
|--------------|-------------------|
| P ∧ Q | P × Q (Prod) |
| P ∨ Q | P ⊕ Q (Sum) |
| P → Q | P → Q (function) |
| P ↔ Q | (P → Q) × (Q → P) |
| True | Unit |
| False | Empty |
| ¬P | P → Empty |

| Logic Operation | Computational Operation |
|-----------------|------------------------|
| And.intro p q | (p, q) or Prod.mk p q |
| h.left, h.right | h.fst, h.snd |
| Or.inl p | Sum.inl p |
| Or.inr q | Sum.inr q |
| Or.elim | match on Sum |
| False.elim | nomatch on Empty |

## Key Theorems Proven

### And Properties
- Commutativity: `P ∧ Q ↔ Q ∧ P`
- Associativity: `(P ∧ Q) ∧ R ↔ P ∧ (Q ∧ R)`

### Or Properties
- Commutativity: `P ∨ Q ↔ Q ∨ P`
- Associativity: `(P ∨ Q) ∨ R ↔ P ∨ (Q ∨ R)`

### Implication Properties
- Reflexivity: `P → P`
- Transitivity: `(P → Q) → (Q → R) → (P → R)`

### Iff Properties
- Reflexivity: `P ↔ P`
- Symmetry: `(P ↔ Q) → (Q ↔ P)`
- Transitivity: `(P ↔ Q) → (Q ↔ R) → (P ↔ R)`

### Key Identities
- `False → P` (ex falso quodlibet)
- `P → True`
- `False ∨ P ↔ P`
- `True ∧ P ↔ P`
- `¬(P ∧ ¬P)` (no contradiction)

### DeMorgan Laws (Constructive)
- `(¬P ∨ ¬Q) → ¬(P ∧ Q)` ✓
- `¬(P ∨ Q) ↔ (¬P ∧ ¬Q)` ✓
- `¬(P ∧ Q) → (¬P ∨ ¬Q)` ✗ (requires classical logic)
@@@ -/

namespace Alpha.book1lib.chapters.C11_summary

/- @@@
## Comprehensive Exercises

These exercises combine multiple connectives. They are roughly
ordered by difficulty.

### Warm-up Exercises
@@@ -/

-- EXERCISE 1: And is idempotent
theorem and_idemp {P : Prop} : P ↔ P ∧ P := by
  sorry

-- EXERCISE 2: Or is idempotent
theorem or_idemp {P : Prop} : P ↔ P ∨ P := by
  sorry

-- EXERCISE 3: And absorbs Or
theorem and_absorb_or {P Q : Prop} : P ∧ (P ∨ Q) ↔ P := by
  sorry

-- EXERCISE 4: Or absorbs And
theorem or_absorb_and {P Q : Prop} : P ∨ (P ∧ Q) ↔ P := by
  sorry

/- @@@
### Distribution Exercises
@@@ -/

-- EXERCISE 5: And distributes over Or
theorem and_distrib_or {P Q R : Prop} :
  P ∧ (Q ∨ R) ↔ (P ∧ Q) ∨ (P ∧ R) := by
  sorry

-- EXERCISE 6: Or distributes over And
theorem or_distrib_and {P Q R : Prop} :
  P ∨ (Q ∧ R) ↔ (P ∨ Q) ∧ (P ∨ R) := by
  sorry

/- @@@
### Implication Exercises
@@@ -/

-- EXERCISE 7: Implication is contrapositive (one direction)
-- Note: The reverse requires classical logic
theorem contrapositive {P Q : Prop} : (P → Q) → (¬Q → ¬P) := by
  sorry

-- EXERCISE 8: Modus tollens
theorem modus_tollens {P Q : Prop} : (P → Q) → ¬Q → ¬P := by
  sorry

-- EXERCISE 9: Hypothetical syllogism (transitivity of →)
theorem hyp_syllogism {P Q R : Prop} : (P → Q) → (Q → R) → (P → R) := by
  sorry

/- @@@
### Negation Exercises
@@@ -/

-- EXERCISE 10: Double negation introduction
-- Note: Elimination (¬¬P → P) requires classical logic!
theorem double_neg_intro {P : Prop} : P → ¬¬P := by
  sorry

-- EXERCISE 11: Triple negation reduces to single
theorem triple_neg {P : Prop} : ¬¬¬P ↔ ¬P := by
  sorry

-- EXERCISE 12: Negation of implication (one direction)
theorem neg_imp_and {P Q : Prop} : (¬(P → Q)) → (P ∧ ¬Q) := by
  sorry  -- CHALLENGE: This actually requires classical logic!

-- The constructive direction:
theorem and_imp_neg_imp {P Q : Prop} : (P ∧ ¬Q) → ¬(P → Q) := by
  sorry

/- @@@
### Complex Exercises
@@@ -/

-- EXERCISE 13: Prove this tautology
theorem complex1 {P Q R : Prop} :
  ((P → Q) ∧ (Q → R)) → (P → R) := by
  sorry

-- EXERCISE 14: Prove this tautology
theorem complex2 {P Q R : Prop} :
  (P → Q → R) ↔ (P ∧ Q → R) := by
  sorry

-- EXERCISE 15: Prove this tautology (currying)
theorem curry {P Q R : Prop} :
  (P ∧ Q → R) ↔ (P → Q → R) := by
  sorry

-- EXERCISE 16: Prove this tautology
theorem complex3 {P Q : Prop} :
  (P → Q) → (¬P ∨ Q) := by
  sorry  -- CHALLENGE: Requires classical logic!

-- The constructive theorem we CAN prove:
theorem complex3_converse {P Q : Prop} :
  (¬P ∨ Q) → (P → Q) := by
  sorry

/- @@@
### Challenge Exercises

These are harder. Some may require techniques from Book II.
@@@ -/

-- CHALLENGE 1: Peirce's law is NOT constructively provable
-- But its double negation IS provable!
theorem peirce_double_neg {P Q : Prop} :
  ¬¬((P → Q) → P) → P := by
  sorry  -- Actually requires classical logic

-- CHALLENGE 2: Prove equivalence of these forms
theorem iff_neg_or {P Q : Prop} :
  (P → Q) ↔ (¬P ∨ Q) := by
  sorry  -- Forward direction requires classical logic

-- What we CAN prove constructively:
theorem imp_from_neg_or {P Q : Prop} : (¬P ∨ Q) → (P → Q) := by
  sorry

/- @@@
## Preview of Book II: Predicate Logic

Book II extends our logic with:

### Universal Quantification (∀)
@@@ -/

-- To prove ∀ x, P x: introduce arbitrary x, prove P x
example : ∀ (n : Nat), n = n := fun n => rfl

-- To use ∀ x, P x: apply to specific value
example (h : ∀ n : Nat, n + 0 = n) : 5 + 0 = 5 := h 5

/- @@@
### Existential Quantification (∃)
@@@ -/

-- To prove ∃ x, P x: provide witness and proof
example : ∃ (n : Nat), n > 0 := ⟨1, Nat.one_pos⟩

-- To use ∃ x, P x: extract witness and proof
example (h : ∃ n : Nat, n > 0) : True :=
  match h with | ⟨n, _⟩ => True.intro

/- @@@
### Equality
@@@ -/

-- Reflexivity: rfl proves a = a
example : 5 = 5 := rfl

-- Substitution: if a = b, can replace a with b
example (h : x = y) : x + 1 = y + 1 := by rw [h]

/- @@@
### Induction
@@@ -/

-- Prove property for all natural numbers by induction
theorem add_zero (n : Nat) : n + 0 = n := by
  induction n with
  | zero => rfl
  | succ n ih => simp [Nat.succ_add, ih]

/- @@@
### Classical Logic
@@@ -/

-- With classical logic, we can use:
-- • Law of excluded middle: P ∨ ¬P
-- • Double negation elimination: ¬¬P → P
-- • Proof by contradiction

open Classical in
example {P : Prop} : P ∨ ¬P := em P

/- @@@
## Congratulations!

If you've worked through all the chapters and exercises in Book I,
you now understand:

1. **Propositions as types**: Every proposition is a type, every
   proof is a value of that type.

2. **The inference rules**: You know how to introduce and eliminate
   And, Or, Implies, Iff, True, False, and Not.

3. **Constructive vs classical**: You understand what can be proven
   constructively and what requires classical axioms.

4. **The Curry-Howard correspondence**: You see how logical reasoning
   mirrors computational programming.

You're ready for Book II, where we'll add quantifiers and induction,
giving you the full power of predicate logic!
@@@ -/

end Alpha.book1lib.chapters.C11_summary
