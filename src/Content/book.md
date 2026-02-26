# Reasoning and Computation

**Kevin Sullivan**
*Department of Computer Science, University of Virginia*

CS 6501, Spring 2026

---

A course in logic and discrete mathematics formalized
in the Lean 4 proof assistant. Every definition, theorem,
and example in this text is machine-checked code.

## Contents

### I. Data and Function Types

Basic types (Bool, Nat, String), function definitions,
pattern matching, and case analysis in Lean 4.

### II. Constructive Propositional Logic

A shallow embedding of propositional logic into Lean's
type universe via the Curry-Howard correspondence.
Propositions are types; proofs are values. Covers
conjunction (products), disjunction (sums), negation
(empty types), implication (functions), and equivalence.

### III. Classical Propositional Logic

A deep embedding: syntax, semantics, and decision
procedures for propositional logic. Boolean algebra,
interpretations, truth tables, models, counterexamples,
validity, satisfiability, and a working demonstration.

### IV. Inductive Types and Higher-Order Functions

Nat, List, and Option as inductive types. Map, fold,
and reduce as higher-order functions, applied to our
propositional logic property checker.

### V. Algebraic Structures

Typeclasses in Lean and Mathlib. Building an AddMonoid
and AddGroup for a three-hour clock, layer by layer
through the Mathlib hierarchy. Dependent types and
certified programming.
