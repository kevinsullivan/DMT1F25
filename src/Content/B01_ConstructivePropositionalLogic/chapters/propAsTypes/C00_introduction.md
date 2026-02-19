# Constructive Propositional Logic

<!-- toc -->

Classical propositional logic is truth-theoretic. You
evaluate a proposition and get back one bit: true or
false. Constructive propositional logic is different.
A deduction yields a detailed, machine-checkable proof
that explains *why* a proposition is valid, with no
gaps, all the way down to basic axioms.

The key idea is the *Curry-Howard correspondence*:
propositions are types, and proofs are values. A type
that has a value is a true proposition. A type with no
values is a false proposition. Logic becomes programming.

We give a *shallow embedding* of constructive
propositional logic into Lean, using only ordinary
programming types — products, sums, functions, and
empty types — all living in Type, not Prop.

```
Classical PL        Type Embedding

proposition         Type
false               Empty
true                Unit
P ∧ Q               Prod P Q  (P × Q)
P ∨ Q               Sum P Q   (P ⊕ Q)
P → Q               P → Q
P ↔ Q               (P → Q) × (Q → P)
¬P                  P → Empty
```

The subsequent chapters build up each row of this
table, covering the introduction (construction) and
elimination (use) rules for each connective.

## Atomic Propositions

A proposition is a type. A proof is a value of that
type. We start with two simple propositions, each
with exactly one proof.

```lean
namespace Content.B01_ConstructivePropositionalLogic.chapters.propAsTypes.C00_introduction

-- "The sky is blue" as a type with one proof
inductive SkyBlue : Type where
| intro

-- "The earth is green" as a type with one proof
inductive EarthGreen : Type where
| intro

-- Proofs: values that witness truth
def pfSkyBlue : SkyBlue := SkyBlue.intro
def pfEarthGreen : EarthGreen := EarthGreen.intro
```

Each of these types has exactly one constructor, so
each has exactly one proof. A proposition with a proof
is true. In the chapters that follow, we will see how
the logical connectives — and, or, not, implies — are
represented using basic data and function types, and
how their introduction and elimination rules arise
naturally from this encoding.

```lean
end Content.B01_ConstructivePropositionalLogic.chapters.propAsTypes.C00_introduction
```
