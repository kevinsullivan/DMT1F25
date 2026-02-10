```lean
import Content.B02_ClassicalPropositionalLogic.chapters.properties
import Content.B02_ClassicalPropositionalLogic.chapters.truthTable
import Content.B02_ClassicalPropositionalLogic.chapters.counterexamples
import Content.B02_ClassicalPropositionalLogic.chapters.interpretation
import Content.B02_ClassicalPropositionalLogic.chapters.semantics
import Content.B02_ClassicalPropositionalLogic.chapters.syntax

namespace Content.B02_ClassicalPropositionalLogic.chapters.propLogic

open Content.B02_ClassicalPropositionalLogic.chapters.syntax
open Content.B02_ClassicalPropositionalLogic.chapters.interpretation
open Content.B02_ClassicalPropositionalLogic.chapters.models
open Content.B02_ClassicalPropositionalLogic.chapters.truthTable
open Content.B02_ClassicalPropositionalLogic.chapters.properties
open Content.B02_ClassicalPropositionalLogic.chapters.counterexamples
```

# Propositional Logic: A Working Demonstration

This file demonstrates what our propositional logic
implementation can do. We'll build expressions using
familiar logical connectives, then use automated tools
to analyze their properties, find models, and discover
counterexamples.

## Setting Up: Propositional Variables

We start by defining propositional variables P, Q, and R.
Each is built from a Var (with a numeric index) wrapped
in a variable expression.

```lean
-- Variables (the building blocks)
def v₀ : Var := Var.mk 0    -- abstract syntax
def v₁ : Var := ⟨1⟩         -- Lean's anonymous constructor
def v₂ : Var := ⟨2⟩

-- Variable expressions (what we use in formulas)
def P : Expr := Expr.var_expr v₀   -- abstract syntax
def Q : Expr := { v₁ }            -- our { } notation
def R : Expr := { v₂ }
```

## Building Expressions

We can now write propositional logic formulas using
the standard connectives: ¬ (not), ∧ (and), ∨ (or),
⇒ (implies), and ↔ (if and only if). Lean also gives
us ⊤ (true) and ⊥ (false) as literal expressions.

```lean
-- These are all expressions of type Expr
#check (P ∧ Q)
#check (P ∨ ¬Q)
#check (P ⇒ Q)
#check (P ↔ Q)
```

Behind the notation, these are trees built from our
abstract syntax. We can see the desugared form:

```lean
#reduce (P ∧ Q)
```
This prints the abstract syntax tree:
  bin_op_expr BinOp.and (var_expr { index := 0 }) (var_expr { index := 1 })

But our ToString instance prints using familiar notation:
```lean
#eval toString (P ∧ Q)              -- "P ∧ Q"
#eval toString (P ⇒ Q ∧ ¬R)        -- "P ⇒ Q ∧ ¬R"
#eval toString ((P ∨ Q) ∧ R)       -- "(P ∨ Q) ∧ R"
#eval toString (P ⇒ Q ⇒ R)        -- "P ⇒ Q ⇒ R"
```

## First Taste: What Can This System Do?

Here's the payoff. Given any propositional logic expression,
our system can automatically determine whether it's valid
(true in every possible world), find models (worlds where
it's true), and find counterexamples (worlds where it fails).

```lean
-- Is "P or not P" valid? (The law of the excluded middle)
#eval is_valid (P ∨ ¬P)           -- true

-- Is "P implies Q" valid? (Not every implication is a law)
#eval is_valid (P ⇒ Q)            -- false

-- Which worlds make it false? Let's find out.
-- Each list is an interpretation: [P-value, Q-value]
#eval bitListsFromInterpsHelper
        (findCounterexamples (P ⇒ Q)) 2
-- [[true, false]]: the only counterexample has P true, Q false
```

## Truth Tables

The *truthTableOutputs* function evaluates an expression
under every interpretation, producing the output column
of its truth table (in ascending order, from all-false
to all-true).

```lean
#eval truthTableOutputs P           -- [false, true]
#eval truthTableOutputs (P ∧ Q)     -- [false, false, false, true]
#eval truthTableOutputs (P ∨ Q)     -- [false, true, true, true]
#eval truthTableOutputs (P ⇒ Q)     -- [true, true, false, true]
```

## Three Kinds of Expressions

Every propositional expression falls into exactly one of
three categories. These are the most important properties
in propositional logic.

**Valid**: true under every interpretation (a tautology).

```lean
#eval is_valid (P ∨ ¬P)       -- true
#eval is_sat   (P ∨ ¬P)       -- true (valid implies satisfiable)
#eval is_unsat (P ∨ ¬P)       -- false
```

**Satisfiable but not valid**: true in some worlds, false
in others. Most "interesting" propositions are like this.

```lean
#eval is_valid (P ∧ Q)        -- false
#eval is_sat   (P ∧ Q)        -- true
#eval is_unsat (P ∧ Q)        -- false
```


## Models and Counterexamples

A *model* of an expression is an interpretation that makes
it true. A *counterexample* is an interpretation that makes
it false. Our system can find all of them.

To read the output, recall that each list of Booleans gives
the values assigned to variables in order: the first element
is P, the second Q, the third R (if present).

```lean
-- P ∧ Q: only one model (both true)
#eval bitListsFromInterpsHelper (findModels (P ∧ Q)) 2
-- [[true, true]]

-- P ∨ Q: three models (at least one true)
#eval bitListsFromInterpsHelper (findModels (P ∨ Q)) 2
-- [[false, true], [true, false], [true, true]]

-- P ↔ Q: two models (both same value)
#eval bitListsFromInterpsHelper (findModels (P ↔ Q)) 2
-- [[false, false], [true, true]]

-- A valid expression has no counterexamples
#eval bitListsFromInterpsHelper (findCounterexamples (P ∨ ¬P)) 1
-- [] (empty list)

-- An unsatisfiable expression has no models
#eval bitListsFromInterpsHelper (findModels (P ∧ ¬P)) 1
-- [] (empty list)
```

## Reasoning Patterns: Implication and Its Relatives

In everyday reasoning, people often confuse an implication
with its converse, inverse, or contrapositive. Our system
can show us exactly which of these are equivalent and which
are not.

```lean
def implication    := P ⇒ Q       -- if P then Q
def converse       := Q ⇒ P       -- if Q then P
def inverse        := ¬P ⇒ ¬Q     -- if not P then not Q
def contrapositive := ¬Q ⇒ ¬P     -- if not Q then not P

#eval is_valid ((P ⇒ Q) ⇒ (¬Q ⇒ ¬P))


-- Compare their truth tables
#eval truthTableOutputs implication      -- [true, true, false, true]
#eval truthTableOutputs converse         -- [true, false, true, true]
#eval truthTableOutputs inverse          -- [true, false, true, true]
#eval truthTableOutputs contrapositive   -- [true, true, false, true]
```

Look carefully: implication and contrapositive have the
same output column. So do converse and inverse. But the
two pairs differ from each other.

We can verify these equivalences directly. Two expressions
are logically equivalent when their biconditional is valid.

```lean
-- Implication ↔ contrapositive: equivalent
#eval is_valid (implication ↔ contrapositive)   -- true

-- Converse ↔ inverse: equivalent
#eval is_valid (converse ↔ inverse)             -- true

-- Implication ↔ converse: NOT equivalent
#eval is_valid (implication ↔ converse)          -- false
```

### The Inverse Error

"If it's raining, then the ground is wet."
Does that mean "if it's NOT raining, then the ground
is NOT wet"? Many people reason this way. This is
called the *inverse error* (or *denying the antecedent*).

Let's ask: is it valid that an implication entails its
inverse?

```lean
#eval is_valid ((P ⇒ Q) ⇒ (¬P ⇒ ¬Q))   -- false!

-- What's the counterexample?
#eval bitListsFromInterpsHelper
        (findCounterexamples ((P ⇒ Q) ⇒ (¬P ⇒ ¬Q))) 2
-- [[false, true]]: P is false, Q is true
-- The sprinkler is on! The ground is wet even though
-- it's not raining.
```

But the contrapositive *is* always valid:

```lean
#eval is_valid ((P ⇒ Q) ⇒ (¬Q ⇒ ¬P))   -- true
```

## Verifying Logical Equivalences

We can use our system as an equivalence checker. Two
expressions are equivalent exactly when their biconditional
is valid (true under all interpretations).

```lean
-- De Morgan's Laws
#eval is_valid (¬(P ∧ Q) ↔ (¬P ∨ ¬Q))   -- true
#eval is_valid (¬(P ∨ Q) ↔ (¬P ∧ ¬Q))   -- true

-- Double negation elimination
#eval is_valid (¬¬P ↔ P)                 -- true

-- Distribution of ∧ over ∨ (and vice versa)
#eval is_valid ((P ∧ (Q ∨ R)) ↔ ((P ∧ Q) ∨ (P ∧ R)))  -- true
#eval is_valid ((P ∨ (Q ∧ R)) ↔ ((P ∨ Q) ∧ (P ∨ R)))  -- true
```

## Three-Variable Examples

With three variables the system generates 2³ = 8
interpretations, and the model sets get more interesting.

```lean
-- Majority: at least two of P, Q, R are true
def majority := (P ∧ Q) ∨ (P ∧ R) ∨ (Q ∧ R)
#eval bitListsFromInterpsHelper (findModels majority) 3
-- four models: [FTT], [TFT], [TTF], [TTT]

-- Exclusive or (exactly one of P, Q is true)
def xor_PQ := (P ∨ Q) ∧ ¬(P ∧ Q)
#eval bitListsFromInterpsHelper (findModels xor_PQ) 2
-- [[false, true], [true, false]]

-- A chain of implications with P forced true
def chain := (P ⇒ Q) ∧ (Q ⇒ R) ∧ P
#eval bitListsFromInterpsHelper (findModels chain) 3
-- just one model: P, Q, R all true
```

## Challenge

Before evaluating the next expression, predict: how many
models does it have? What are they?

Hint: think about what (P ⇒ Q) ∧ (Q ⇒ R) constrains when
P is *not* forced to be true.

```lean
def challenge := (P ⇒ Q) ∧ (Q ⇒ R)














#eval bitListsFromInterpsHelper (findModels challenge) 3

end Content.B02_ClassicalPropositionalLogic.chapters.propLogic
```
