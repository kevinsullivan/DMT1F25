# Book 2: Constructive Predicate Logic
## Quantifiers, Equality, and Induction in Lean

### Overview

This book extends constructive propositional logic (Book 1) with the 
machinery of predicate logic: quantifiers, equality, and induction. 
Students learn to express and prove properties about all elements of 
a type, prove existence claims by providing witnesses, and use 
induction to prove properties of recursive structures.

### Prerequisites

- **Book 1: Constructive Propositional Logic** (required)

### Planned Chapters

| Chapter | Topic | Key Concepts |
|---------|-------|--------------|
| C00 | Introduction | From propositional to predicate logic |
| C01 | Predicates | Properties as functions to Prop |
| C02 | Universal (∀) | `∀ x, P x`, introduction and elimination |
| C03 | Existential (∃) | `∃ x, P x`, witnesses, `Exists.intro` |
| C04 | Equality | `=`, `rfl`, `Eq.subst`, rewriting |
| C05 | Induction | Nat induction, structural induction |
| C06 | Relations | Binary predicates, properties |
| C07 | Summary | Reference and exercises |

### Key Ideas

- **Predicates**: Functions `α → Prop` representing properties
- **Universal Quantification**: "For all x, P x holds"
  - Prove by: assume arbitrary x, prove P x
  - Use by: apply to specific value
- **Existential Quantification**: "There exists x such that P x"
  - Prove by: provide witness and proof
  - Use by: extract witness and proof (in context)
- **Equality**: Built-in reflexive relation with substitution
- **Induction**: Prove base case + inductive step

### Curry-Howard Extensions

| Logic | Computation |
|-------|-------------|
| ∀ (x : α), P x | (x : α) → P x (dependent function) |
| ∃ (x : α), P x | Σ (x : α), P x (dependent pair) |
| a = b | Path/identity type |

### Learning Outcomes

After completing this book, students will be able to:

1. Define predicates as functions returning propositions
2. Prove universally quantified statements
3. Prove existential statements by providing witnesses
4. Use equality and rewriting in proofs
5. Apply induction principles
6. Work with binary relations and their properties

### Status

**Under Development** - Chapter content to be added.

### Namespace Convention

All chapters use: `namespace Alpha.book2lib.chapters.CXX_name`
