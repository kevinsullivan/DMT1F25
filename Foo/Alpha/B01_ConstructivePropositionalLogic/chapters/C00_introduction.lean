/- @@@
# Book I: Constructive Logic

## Introduction and Roadmap

Welcome to *Constructive Logic*, the first book in the Discrete
Mathematics in Type Theory series. This book introduces you to
a revolutionary way of thinking about logic and proof: the idea
that propositions are types and proofs are programs.

<!-- toc -->

## What This Book Is About

In traditional mathematics courses, you learn to write proofs as
sequences of English sentences with occasional mathematical notation.
A human reader (usually a grader or professor) checks whether your
reasoning is valid.

This book takes a radically different approach. You will write proofs
as *programs* in the Lean 4 programming language. The computer checks
your proofs automatically and instantly. If your proof compiles, it's
correct. If it doesn't, you have a bug to fix.

This might sound limiting, but it's actually liberating:
- No more wondering "is this proof rigorous enough?"
- No more waiting for feedback on whether your reasoning is valid
- You can experiment freely and get immediate feedback

## The Curry-Howard Correspondence

The deep insight underlying this book is the *Curry-Howard correspondence*,
discovered independently by logician Haskell Curry and mathematician
William Howard in the mid-20th century.

The correspondence states:

| Logic | Programming |
|-------|-------------|
| Propositions | Types |
| Proofs | Programs (values) |
| Proving P | Constructing a value of type P |
| P implies Q | Function type P → Q |
| P and Q | Product type P × Q |
| P or Q | Sum type P ⊕ Q |
| False | Empty type (no values) |
| True | Unit type (one value) |

When you prove `P → Q` in this book, you literally write a function
that takes a proof of P as input and produces a proof of Q as output.
When you prove `P ∧ Q`, you construct a pair containing a proof of P
and a proof of Q.

This is not merely an analogy—it's a precise mathematical equivalence.

## Prerequisites

To succeed in this book, you should have:

1. **Basic programming experience**: You should be comfortable with
   functions, types, and variables in some programming language.
   Experience with functional programming (Haskell, OCaml, F#, Scala)
   is helpful but not required.

2. **Lean 4 installation**: You'll need Lean 4 and a suitable editor
   (VS Code with the Lean extension is recommended). See the Lean 4
   documentation for installation instructions.

3. **Mathematical curiosity**: No prior logic or proof experience is
   assumed. We build everything from the ground up.

## How to Use This Book

### Reading the Chapters

Each chapter is a *literate Lean file*—a mixture of explanatory text
(in special comments) and executable Lean code. You should:

1. Open each file in your Lean-enabled editor
2. Read the explanations carefully
3. Study the code examples
4. Hover over terms to see their types
5. Experiment by modifying code and seeing what happens

### Completing Exercises

Exercises are marked with `-- EXERCISE` comments. To complete them:

1. Find the `sorry` placeholder
2. Replace `sorry` with your proof
3. If Lean shows no errors, your proof is correct!

Some exercises are marked `-- CHALLENGE` (optional, harder) or
`-- IMPOSSIBLE` (demonstrations that certain things can't be proven).

### The Logical Connectives

This book covers the following logical connectives in order:

| Chapter | Connective | Symbol | Key Idea |
|---------|------------|--------|----------|
| C01 | True | ⊤ | Always provable (trivial) |
| C02 | And | ∧ | Pairs of proofs |
| C03 | Implies | → | Functions on proofs |
| C04-05 | (Functions) | | Programming foundations |
| C06 | Iff | ↔ | Bidirectional implication |
| C07 | Or | ∨ | Tagged union of proofs |
| C08 | False | ⊥ | No proofs exist |
| C09 | Negation | ¬ | Defined as P → False |
| C10 | Curry-Howard | | Computational parallels |

### Inference Rules

For each connective, we present:

- **Introduction rules**: How to *construct* a proof of that form
- **Elimination rules**: How to *use* a proof of that form

This pattern—introduction and elimination—is the key to understanding
how each connective works.

## Constructive vs Classical Logic

This book teaches *constructive* (also called *intuitionistic*) logic.
In constructive logic:

- To prove `P ∨ Q`, you must prove P or prove Q (and say which)
- To prove `∃ x, P(x)`, you must exhibit a specific witness x
- The law of excluded middle (`P ∨ ¬P`) is not assumed

This differs from *classical* logic, where:

- `P ∨ ¬P` is always true (law of excluded middle)
- `¬¬P → P` is valid (double negation elimination)
- Proofs by contradiction are always available

Constructive logic is more restrictive, but also more informative:
a constructive proof of existence always produces a witness.

We explore classical reasoning in Book II.

## What Comes Next

After completing Book I, you'll be ready for:

- **Book II**: Predicate logic (∀, ∃), equality, induction
- **Book III**: Sets, relations, functions
- **Book IV**: Abstract algebra
- **Book V**: Advanced type theory

## Tips for Success

1. **Type everything yourself**: Don't just read—type the examples
   and see them work (or fail) in your editor.

2. **Use the InfoView**: Hover over terms, click on proof states,
   explore what Lean knows at each point.

3. **Embrace errors**: Lean's error messages are your friends. They
   tell you exactly what's wrong and often suggest fixes.

4. **Work incrementally**: Build proofs step by step. Use `sorry` as
   a placeholder while you work on one part.

5. **Review the inference rules**: When stuck, ask yourself: "What
   introduction or elimination rule applies here?"

Let's begin!
@@@ -/

namespace Content.book1lib.chapters.C00_introduction

/- @@@
## A First Example

Before diving into the chapters, let's see a tiny example of
proof-as-programming. We'll prove that if P is true, then P is true.
This is the simplest possible theorem: P → P.
@@@ -/

-- P → P: Given a proof of P, return that same proof
example (P : Prop) : P → P :=
  fun (p : P) => p

/- @@@
That's it! The proof is a function that takes a proof `p` of `P`
and returns... `p`. The identity function *is* the proof that
P implies P.

Now let's see a slightly more interesting example: if we have
both P and Q, we can conclude P.
@@@ -/

-- P ∧ Q → P: Given a proof of P ∧ Q, extract the proof of P
example (P Q : Prop) : P ∧ Q → P :=
  fun (h : P ∧ Q) => h.left

/- @@@
The proof takes a conjunction `h : P ∧ Q` and extracts its left
component using `.left`. This returns a proof of P.

These examples preview what you'll learn in the chapters ahead.
Each chapter builds on the previous ones, gradually expanding
your toolkit for constructing proofs.

Ready? Turn to C01_true.lean to begin!
@@@ -/

end Content.book1lib.chapters.C00_introduction
