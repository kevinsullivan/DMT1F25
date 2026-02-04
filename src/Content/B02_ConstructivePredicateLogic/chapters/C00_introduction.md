# Book 2: Constructive Predicate Logic

## Introduction

This book extends constructive propositional logic (Book 1) with
the machinery needed to express and prove statements about:

- **All** elements of a type (universal quantification, ∀)
- **Some** elements of a type (existential quantification, ∃)
- **Equality** between values (=)
- **Inductive** structures and proofs by induction

## Prerequisites

You should have completed Book 1: Constructive Propositional Logic,
and be comfortable with:

- Constructing proofs of And, Or, Implies, Iff, Not
- The Curry-Howard correspondence (propositions as types)
- Lambda abstractions and pattern matching
- Introduction and elimination rules

## What's New

### From Propositions to Predicates

In Book 1, we worked with propositions like P, Q, R that were
simply assumed to be of type Prop. In Book 2, we work with
**predicates**: functions that take a value and return a proposition.

```lean
-- Book 1: P is just a proposition
axiom P : Prop

-- Book 2: isEven is a predicate on natural numbers
def isEven : Nat → Prop := fun n => n % 2 = 0
```

### Quantifiers

**Universal (∀)**: "For all x of type α, P x holds"

```lean
example : ∀ (n : Nat), n = n := fun n => rfl
```

**Existential (∃)**: "There exists x of type α such that P x"

```lean
example : ∃ (n : Nat), isEven n := ⟨4, rfl⟩
```

### Equality

Equality is reflexive (`rfl`), symmetric, and transitive.
We can substitute equals for equals in proofs.

```lean
example (a b : Nat) (h : a = b) : b = a := h.symm
```

## Chapter Overview

| Chapter | Topic                          |
| ------- | ------------------------------ |
| C01     | Predicates and Properties      |
| C02     | Universal Quantification (∀)   |
| C03     | Existential Quantification (∃) |
| C04     | Equality and Rewriting         |
| C05     | Induction Principles           |
| C06     | Relations and Their Properties |
| C07     | Summary and Reference          |

## Curry-Howard Extensions

| Logic          | Type            |
| -------------- | --------------- |
| ∀ (x : α), P x | (x : α) → P x   |
| ∃ (x : α), P x | Σ' (x : α), P x |
| a = b          | Eq a b          |

```lean
namespace Content.book2lib.chapters.C00_introduction

-- Content to be developed

end Content.book2lib.chapters.C00_introduction
```
