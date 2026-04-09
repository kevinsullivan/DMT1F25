# Equality in Lean

<!-- toc -->

Equality is one of the most basic concepts in mathematics, but
in a type theory like Lean's it has surprising depth. There are
several distinct notions of equality, each serving a different
purpose:

- **Definitional equality**: two terms that compute to the same
  normal form — the kernel checks this silently.
- **Propositional equality** (`Eq`): the inductive type `a = b`,
  which must be proved explicitly.
- **Heterogeneous equality** (`HEq`): equality between terms of
  potentially different types.

We will build all three from the ground up, along with the key
proof techniques: reflexivity, symmetry, transitivity, substitution,
congruence, rewriting, and calculational chains. We finish with
type casts, decidable equality, and exercises.

```lean
namespace Content.B07_Equality.chapters.CS6501_Equality
```

## Definitional Equality

Two expressions are *definitionally equal* when Lean's kernel can
reduce them to the same normal form. No proof is needed — the type
checker verifies this automatically. The `rfl` proof term witnesses
definitional equality.

```lean
-- 2 + 3 and 5 reduce to the same value
example : 2 + 3 = 5 := rfl

-- Function application: (fun x => x + 1) 4 reduces to 5
example : (fun x => x + 1) 4 = 5 := rfl

-- List.length [1, 2, 3] reduces to 3
example : List.length [1, 2, 3] = 3 := rfl
```

Use `#reduce` to see what Lean's kernel reduces a term to.
If two terms `#reduce` to the same thing, they are definitionally
equal and `rfl` will close the goal.

```lean
#reduce 2 + 3           -- 5
#reduce (fun x => x + 1) 4   -- 5
```

Definitional equality is *silent* — the kernel handles it without
you writing anything. But not all true equalities are definitional.
For example, `n + 0 = n` is true for every natural number, but it
is *not* definitional because `+` is defined by recursion on its
*first* argument. Lean cannot reduce `n + 0` without knowing what
`n` is. Proving such equalities requires the machinery of
propositional equality.

```lean
-- This works: 0 + n reduces to n by definition
example (n : Nat) : 0 + n = n := rfl

-- This does NOT work with rfl: n + 0 requires a proof by induction
-- example (n : Nat) : n + 0 = n := rfl   -- ERROR
```

## Propositional Equality: The `Eq` Type

Lean's equality type is an inductive family with one constructor:

```
inductive Eq : α → α → Prop where
  | refl (a : α) : Eq a a
```

The notation `a = b` is sugar for `@Eq α a b`. The only way to
*construct* a proof of `a = b` is `Eq.refl a`, which requires
`a` and `b` to be definitionally equal. The tactic `rfl` applies
`Eq.refl` automatically.

The key insight: `Eq` has only one constructor, so any proof of
`a = b` must ultimately be built from `refl`. This means `a` and
`b` must be "the same" in a deep sense — possibly after reduction
and rewriting.

```lean
#check @Eq              -- Eq : α → α → Prop
#check @Eq.refl         -- Eq.refl : (a : α) → a = a
#print Eq               -- inductive Eq : α → α → Prop

-- Explicit proof term vs rfl sugar
example : 42 = 42 := Eq.refl 42
example : 42 = 42 := rfl

-- Equality is a proposition — a type in Prop
#check (rfl : 1 + 1 = 2)       -- 1 + 1 = 2
```

## Symmetry and Transitivity

From a single proof of `a = b`, we can derive `b = a`. From proofs
of `a = b` and `b = c`, we can derive `a = c`. These are
`Eq.symm` and `Eq.trans`.

```lean
#check @Eq.symm         -- {a b : α} → a = b → b = a
#check @Eq.trans        -- {a b c : α} → a = b → b = c → a = c

-- Using Eq.symm: flip an equation
example (h : 3 = 3) : 3 = 3 := h.symm

-- Using Eq.trans: chain two equalities
example (a b c : Nat) (h1 : a = b) (h2 : b = c) : a = c :=
  h1.trans h2
```

### Building Proofs by Hand

Let's prove that equality is an equivalence relation, by hand.
These are term-mode proofs — no tactics.

```lean
-- Reflexivity: for all a, a = a
theorem eq_refl (a : α) : a = a := rfl

-- Symmetry: from a = b derive b = a
theorem eq_symm {a b : α} (h : a = b) : b = a :=
  h ▸ rfl

-- Transitivity: from a = b and b = c derive a = c
theorem eq_trans {a b c : α} (h1 : a = b) (h2 : b = c) : a = c :=
  h2 ▸ h1
```

### Tactic Proofs

The same facts are often easier to prove with tactics. The
`exact` tactic supplies a proof term; `rw` rewrites the goal.

```lean
theorem eq_symm' {a b : α} (h : a = b) : b = a := by
  rw [h]

theorem eq_trans' {a b c : α} (h1 : a = b) (h2 : b = c) : a = c := by
  rw [h1, h2]
```

## Substitution: `Eq.subst`

Substitution is the most fundamental elimination rule for equality.
If `a = b` and you have a proof of some property `P a`, then you
can obtain a proof of `P b`. The function `P` is called the *motive*.

```
Eq.subst : {a b : α} → a = b → P a → P b
```

In other words: equals can be substituted for equals in any context.

```lean
#check @Eq.subst
  -- @Eq.subst : {α : Sort u} → {motive : α → Prop} →
  --             {a b : α} → a = b → motive a → motive b

-- If n = m and n is even, then m is even
example (n m : Nat) (h_eq : n = m) (h_ev : n % 2 = 0) : m % 2 = 0 :=
  h_eq ▸ h_ev

-- Substitution with an explicit motive
example (n m : Nat) (h : n = m) : n + 1 = m + 1 :=
  h ▸ rfl
```

The `▸` notation is shorthand for substitution. Writing `h ▸ goal`
rewrites the goal using `h`. It is the term-mode analogue of the
`rw` tactic.

## Congruence: `congrArg` and `congr`

If `a = b`, then `f a = f b` for any function `f`. This is
*congruence* — functions respect equality.

```lean
#check @congrArg   -- (f : α → β) → a = b → f a = f b
#check @congr      -- f = g → a = b → f a = g b
#check @congrFun   -- f = g → (a : α) → f a = g a

-- Applying a function to both sides of an equation
example (n m : Nat) (h : n = m) : n + 1 = m + 1 :=
  congrArg (· + 1) h

-- If two functions are equal and their arguments are equal,
-- then their results are equal
example (f g : Nat → Nat) (n m : Nat)
    (hfg : f = g) (hnm : n = m) : f n = g m :=
  congr hfg hnm
```

Congruence is how equalities propagate through expressions.
If you know `x = y`, you can conclude `f x = f y`, then
`g (f x) = g (f y)`, and so on — mechanically, one function
application at a time.

## The `rewrite` Tactic

The `rw` (rewrite) tactic is the workhorse for equational
reasoning in tactic mode. Given a proof `h : a = b`, the
tactic `rw [h]` replaces all occurrences of `a` with `b`
in the goal.

```lean
-- Rewriting left to right
example (x y : Nat) (h : x = y) : x + x = y + y := by
  rw [h]

-- Rewriting right to left with ←
example (x y : Nat) (h : x = y) : y + y = x + x := by
  rw [← h]

-- Chaining multiple rewrites
example (a b c : Nat) (h1 : a = b) (h2 : b = c) : a + a = c + c := by
  rw [h1, h2]
```

### Rewriting in Hypotheses

Use `rw [h] at h'` to rewrite in a hypothesis rather than the goal.

```lean
example (x y : Nat) (h : x = y) (h2 : x + 1 = 10) : y + 1 = 10 := by
  rw [h] at h2
  exact h2
```

### Directed Rewriting

Sometimes you need to control the direction. By default `rw [h]`
rewrites left-to-right (replacing `a` with `b` when `h : a = b`).
Use `rw [← h]` to go right-to-left (replacing `b` with `a`).

```lean
example (x y z : Nat) (h1 : x = y) (h2 : z = y) : x = z := by
  rw [h1, ← h2]
```

## Calculational Proofs with `calc`

For longer chains of equational reasoning, Lean provides `calc`
blocks. Each step states an equality and justifies it.

```lean
example (a b c d : Nat) (h1 : a = b) (h2 : b = c) (h3 : c = d) : a = d :=
  calc a = b := h1
    _ = c := h2
    _ = d := h3

-- A more interesting example with arithmetic
example (x y : Nat) (h : x = y) : (x + 1) * 2 = (y + 1) * 2 :=
  calc (x + 1) * 2 = (y + 1) * 2 := by rw [h]

-- calc works with other relations too (≤, <, etc.)
-- but here we focus on equality
```

### A Longer Calculational Proof

Let's prove that if `a = b` and `c = d`, then `a + c = b + d`.

```lean
theorem add_eq_of_eq (a b c d : Nat)
    (hab : a = b) (hcd : c = d) : a + c = b + d :=
  calc a + c
    _ = b + c := by rw [hab]
    _ = b + d := by rw [hcd]
```

## Heterogeneous Equality: `HEq`

Lean's `Eq` requires both sides to have the *same* type:
`@Eq α a b` means `a : α` and `b : α`. But sometimes we need
to state that two values of *different* types are "equal" — this
arises with indexed families and dependent types.

Consider vectors (length-indexed lists). If `v : Vect α n` and
`w : Vect α m`, the statement `v = w` is not even well-typed when
`n ≠ m`, because `Vect α n` and `Vect α m` are different types.
Heterogeneous equality, `HEq`, solves this:

```
inductive HEq : {α : Sort u} → α → {β : Sort u} → β → Prop where
  | refl (a : α) : HEq a a
```

`HEq a b` (notation `a ≅ b`) says: `a` and `b` are equal, even
though they might have different types. But the only constructor
is `refl`, so `HEq a b` can only be proved when the types are
actually the same and `a` is definitionally equal to `b`.

```lean
#check @HEq             -- HEq : α → β → Prop
#check @HEq.refl        -- HEq.refl : (a : α) → HEq a a
#print HEq

-- HEq between values of the same type is just Eq
example : HEq (1 + 1) (2 : Nat) := HEq.refl 2

-- Converting between Eq and HEq
#check @Eq.toHEq        -- a = b → HEq a b
#check @eq_of_heq       -- HEq a b → a = b  (when types match)

example (h : 3 = 3) : HEq 3 3 := Eq.toHEq h
example (h : HEq (2 : Nat) 2) : (2 : Nat) = 2 := eq_of_heq h
```

### When Does `HEq` Arise?

Heterogeneous equality appears naturally when you work with
dependent types — particularly indexed inductive families. Here
is a simple example with length-indexed vectors.

```lean
-- Length-indexed vectors
inductive Vect (α : Type) : Nat → Type where
  | nil  : Vect α 0
  | cons : α → Vect α n → Vect α (n + 1)

-- Two vectors with provably equal lengths
-- We cannot state v1 = v2 directly when n ≠ m syntactically,
-- but we can use HEq.
example : HEq (Vect.nil (α := Nat)) (Vect.nil (α := Nat)) := HEq.refl _
```

In practice, `HEq` goals often appear when Lean cannot unify
index expressions during dependent pattern matching. The usual
strategy is to rewrite the indices until the types match, then
convert to `Eq`.

## Type Casts

When two types are provably equal, we can *cast* a value from
one type to the other. The function `cast` does this:

```
cast : {α β : Sort u} → α = β → α → β
```

Given a proof that `α = β` (an equality of types), `cast`
converts a value of type `α` into a value of type `β`.

```lean
#check @cast           -- cast : α = β → α → β

-- If we know Nat = Nat (trivially), we can cast
example : cast rfl 42 = 42 := rfl
```

### `Eq.mpr` and `Eq.mp`

Closely related to `cast` are `Eq.mp` and `Eq.mpr`:

- `Eq.mp  : α = β → α → β`  (forward: same as `cast`)
- `Eq.mpr : α = β → β → α`  (backward: cast in reverse)

These arise frequently in tactic proofs when the goal type
needs to be transformed by a type equality.

```lean
#check @Eq.mp          -- α = β → α → β
#check @Eq.mpr         -- α = β → β → α
```

### Cast and HEq

There is a fundamental connection: `cast h a` is heterogeneously
equal to `a`. Casting does not change the "value" — it only changes
the type annotation. This is captured by:

```lean
#check @cast_heq       -- (h : α = β) → (a : α) → HEq (cast h a) a
```

This says: after casting, the result is `HEq`-equal to the original.
The value did not change; only the type wrapper did.

## Decidable Equality

So far, equality has been a *proposition* — something we prove in
`Prop`. But sometimes we need to *compute* whether two values are
equal at runtime, inside programs. This is **decidable equality**.

A type has decidable equality when there is an algorithm that,
given any two values, returns either a proof that they are equal
or a proof that they are not. In Lean, this is the `DecidableEq`
typeclass:

```
class DecidableEq (α : Sort u) where
  decEq : (a b : α) → Decidable (a = b)
```

The `Decidable` type is either `isTrue h` (carrying a proof of
the proposition) or `isFalse h` (carrying a proof of its negation).

```lean
#check @DecidableEq     -- (α : Sort u) → Sort (max 1 u)
#check @Decidable       -- Prop → Type

-- Nat has decidable equality
#check (inferInstance : DecidableEq Nat)

-- We can compute equality at runtime
#eval decide (3 = 3)       -- true
#eval decide (3 = 4)       -- false
#eval decide ("hello" = "hello")   -- true
```

### `BEq` vs `Eq`

Lean has two distinct equality interfaces:

- **`Eq`** (`=`): propositional equality in `Prop`. Proof-relevant.
  Used in theorems and specifications.
- **`BEq`** (`==`): boolean equality returning `Bool`. Used in
  programs and `#eval`.

They are connected: if a type has both `BEq` and `DecidableEq`,
then `(a == b) = true ↔ a = b`.

```lean
-- BEq returns a Bool
#eval (3 : Nat) == 3         -- true
#eval (3 : Nat) == 4         -- false

-- Eq returns a Prop
#check (3 : Nat) = 3         -- Prop

-- The decide tactic bridges the gap:
-- it turns a Decidable proposition into a proof
example : (3 : Nat) = 3 := by decide
example : (3 : Nat) ≠ 4 := by decide
```

### Using `decide` in Proofs

The `decide` tactic works for any `Decidable` proposition. It
runs the decision procedure and, if the result is `isTrue h`,
extracts the proof `h`. This is powerful for concrete computations.

```lean
example : 10 * 10 = 100 := by decide
example : "abc".length = 3 := by decide
example : ¬ (7 = 8) := by decide
```

For symbolic (variable-containing) goals, `decide` cannot help —
you need `rfl`, `rw`, or induction.

## A Proof by Induction: `n + 0 = n`

We observed earlier that `n + 0 = n` is not definitional. Let's
prove it by induction on `n`. This uses everything we've learned:
`rfl` for the base case, `congrArg` or `rw` for the inductive step.

```lean
theorem add_zero (n : Nat) : n + 0 = n := by
  induction n with
  | zero => rfl
  | succ n' ih =>
    -- Goal: n' + 1 + 0 = n' + 1
    -- ih : n' + 0 = n'
    -- n' + 1 + 0 reduces to (n' + 0) + 1
    rw [Nat.succ_add, ih]
```

The base case is definitional: `0 + 0 = 0` by the definition of `+`.
The inductive step rewrites using the induction hypothesis. This is
the pattern for most arithmetic proofs about natural numbers.

### Another Example: Commutativity of Addition

We chain together two lemmas to prove `a + b = b + a`.

```lean
-- We use Nat.add_comm from the standard library
#check @Nat.add_comm    -- ∀ (n m : Nat), n + m = m + n

example (a b : Nat) : a + b = b + a := Nat.add_comm a b

-- Let's also see it as a calc proof
example (a b : Nat) : a + b = b + a :=
  calc a + b = b + a := Nat.add_comm a b
```

## Summary

| Concept | Type/Tactic | Purpose |
|---|---|---|
| Definitional equality | (kernel) | Terms that compute to the same value |
| `Eq` / `rfl` | `a = b`, `Eq.refl` | Propositional equality |
| `Eq.symm` | `a = b → b = a` | Flip an equation |
| `Eq.trans` | `a = b → b = c → a = c` | Chain equations |
| `Eq.subst` / `▸` | `a = b → P a → P b` | Substitute equals for equals |
| `congrArg` | `a = b → f a = f b` | Functions respect equality |
| `rw` | tactic | Rewrite in goal or hypothesis |
| `calc` | proof block | Chain of equational steps |
| `HEq` | `HEq a b` | Equality across types |
| `cast` | `α = β → α → β` | Convert between equal types |
| `DecidableEq` | typeclass | Runtime equality checking |
| `BEq` / `==` | typeclass | Boolean equality for programs |
| `decide` | tactic | Prove decidable propositions |


## Exercises

Try to replace each `sorry` with an actual proof. Use `rfl`, `rw`,
`Eq.symm`, `Eq.trans`, `congrArg`, `calc`, and induction as needed.

```lean
-- Exercise 1: Simple reflexivity
theorem ex_refl : 7 = 7 := sorry

-- Exercise 2: Symmetry
theorem ex_symm (a b : Nat) (h : a = b) : b = a := sorry

-- Exercise 3: Transitivity
theorem ex_trans (a b c : Nat) (h1 : a = b) (h2 : b = c) : a = c := sorry

-- Exercise 4: Congruence
theorem ex_congr (n m : Nat) (h : n = m) : n * 2 = m * 2 := sorry

-- Exercise 5: Rewriting
theorem ex_rw (x y z : Nat) (h1 : x = y + 1) (h2 : y = z) : x = z + 1 := sorry

-- Exercise 6: Calc block
theorem ex_calc (a b c : Nat) (h1 : a = b + 1) (h2 : b = c + 1) : a = c + 2 := sorry

-- Exercise 7: Induction (harder)
theorem ex_zero_add (n : Nat) : 0 + n = n := sorry

-- Exercise 8: Using decide
theorem ex_decide : 15 % 5 = 0 := sorry

end Content.B07_Equality.chapters.CS6501_Equality
```
