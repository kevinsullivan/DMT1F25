# Propositional Logic: A Deep Embedding
## Implementing a Logic in Lean

### Overview

This optional module teaches how to implement a logic as a programming 
project in Lean. Unlike Books 1-2, which teach logic by *using* Lean's 
native type system, this module teaches logic by *building* a complete 
propositional logic implementation from scratch.

### What is a "Deep Embedding"?

A **deep embedding** represents the syntax of a logic as data structures
in a host language. This allows us to:

- Define the grammar of logical expressions
- Implement semantic evaluation
- Build decision procedures (SAT solvers, validity checkers)
- Analyze properties of the logic itself

This contrasts with a **shallow embedding** (Books 1-2) where we use the
host language's native logic directly.

### Module Structure

```
book3lib/
└── library/
    ├── syntax.lean         -- AST: Expr, Var, UnOp, BinOp
    ├── domain.lean         -- Semantic domain (Bool)
    ├── semantics.lean      -- eval : Expr → Interp → Bool
    ├── interpretation.lean -- Variable assignments
    ├── axioms.lean         -- Example expressions
    ├── identities.lean     -- Algebraic laws
    ├── utilities.lean      -- Helper functions
    └── model_theory/
        ├── truthTable.lean     -- Truth table generation
        ├── properties.lean     -- is_sat, is_valid, is_unsat
        ├── models.lean         -- Model finding
        └── counterexamples.lean -- Counterexample generation
```

### Key Components

#### Syntax (Abstract Syntax Tree)

```lean
inductive Expr : Type
| lit_expr (b : Bool) : Expr           -- ⊤, ⊥
| var_expr (v : Var) : Expr            -- {P}, {Q}, ...
| un_op_expr (op : UnOp) (e : Expr)    -- ¬e
| bin_op_expr (op : BinOp) (e1 e2 : Expr)  -- e1 ∧ e2, etc.
```

#### Semantics

```lean
def eval : Expr → Interp → Bool
-- Evaluates expression under an interpretation
```

#### Decision Procedures

```lean
def is_sat : Expr → Bool    -- Satisfiability
def is_valid : Expr → Bool  -- Validity (tautology)
def is_unsat : Expr → Bool  -- Unsatisfiability
```

### Learning Outcomes

After completing this module, students will be able to:

1. Design abstract syntax for a formal language
2. Implement semantic evaluation functions
3. Build truth table generators
4. Implement SAT and validity checkers
5. Understand the difference between syntax and semantics
6. Appreciate the difference between deep and shallow embeddings

### Relationship to Books 1-2

| Aspect | Books 1-2 | This Module |
|--------|-----------|-------------|
| Approach | Use Lean's native logic | Build custom logic |
| Student activity | Write proofs | Write interpreters |
| Verification | Type-checked proofs | Boolean computation |
| Logic system | Full predicate logic | Propositional only |

### Prerequisites

- Basic Lean programming (functions, inductive types)
- Book 1 recommended for conceptual background (not required)

### Status

**Optional/Supplementary** - Can be used independently or alongside the main book sequence.

### Namespace Convention

All files use: `namespace Alpha.book3lib.library.<module>`
