# Equality in Lean

<!-- toc -->

Equality is one of the most basic concepts in mathematics, but
in a type theory like Lean's it has surprising depth. There are
three distinct notions of equality, each serving a different
purpose:

- **Definitional equality** (also called *judgmental equality*
  or *convertibility*): a kernel-level notion, not a type. Two
  expressions are definitionally equal when Lean's kernel can
  confirm they are interconvertible by computation and unfolding.
  No proof term is needed — the type checker verifies this
  automatically. Definitional equality is the strongest and most
  convenient notion, because Lean uses it silently in type
  checking, elaboration, and unification.
- **Propositional equality** (`Eq`): the inductive type `a = b`,
  which must be proved explicitly. When two terms are not
  definitionally equal but are still equal, you construct a
  proof term of this type.
- **Heterogeneous equality** (`HEq`): equality between terms
  whose types may differ. This arises mainly in dependent-type
  situations where ordinary `Eq` is too restrictive. When the
  two terms do have the same type, `HEq` and `Eq` are closely
  connected and can often be converted back and forth, but `Eq`
  should remain the default; treat `HEq` as a specialized tool
  for dependent situations.

Note that only `Eq` and `HEq` are equality *types*. Definitional
equality is a judgment of the kernel, not something you state or
prove inside the logic.

We will explore all three from the ground up, along with the key
proof techniques: reflexivity, symmetry, transitivity, substitution,
congruence, rewriting, and calculational chains. We finish with
the dependent equality problem, type casts, and decidable equality.

```lean
namespace Content.B07_Equality.chapters.CS6501_Equality
```

## Definitional Equality

Two expressions are *definitionally equal* (also called *judgmentally
equal* or *convertible*) when Lean's kernel can confirm they are
interconvertible by computation and unfolding. No proof is needed —
the type checker verifies this automatically.

When two expressions are definitionally equal, the `rfl` proof term
can construct a proof of their propositional equality (`Eq`) — but
`rfl` itself is a term of type `Eq`, not a certificate of the kernel
judgment.

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

## The `Eq` Type

Lean's equality type is an inductive family with one constructor:

```
inductive Eq : α → α → Prop where
  | refl (a : α) : Eq a a
```

### Eq.refl: The Introduction Rule

The constructor provides a rule for constructing proofs of
equality — the *introduction rule*. The notation `a = b` is
sugar for `@Eq α a b`. The only way to *construct* a proof of
`a = b` is `Eq.refl a`, which requires `a` and `b` to be
definitionally equal. The tactic `rfl` applies `Eq.refl`
automatically.

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

### Eq.subst: The Elimination Rule

The `Eq` type has one constructor (`refl`) — that's the
*introduction* rule. Now we need the *elimination* rule:
what can we do with a proof of `a = b`?

The answer is **substitution**. If `a = b` and you have a proof
of some property `P a`, then you can obtain a proof of `P b`.
The function `P` is called the *motive*.

```
Eq.subst : {a b : α} → a = b → P a → P b
```

In other words: equals can be substituted for equals in any context.

```lean
#check @Eq.subst
-- @Eq.subst : {α : Sort u} → {motive : α → Prop} →
--             {a b : α} → a = b → motive a → motive b
```

Lean provides a convenient notation for substitution: `▸`
(typed as `\t` or `\blacktriangleleft`). Writing `h ▸ e` where
`h : a = b` rewrites occurrences of `b` with `a` in the expected
type, then checks that `e` has the rewritten type. It is the
term-mode analogue of the `rw` tactic.

```lean
-- If n = m and n is even, then m is even (explicit Eq.subst with motive)
example (n m : Nat) (h_eq : n = m) (h_ev : n % 2 = 0) : m % 2 = 0 :=
  Eq.subst (motive := fun x => x % 2 = 0) h_eq h_ev

-- Same example using ▸ notation (Lean infers the motive)
example (n m : Nat) (h_eq : n = m) (h_ev : n % 2 = 0) : m % 2 = 0 :=
  h_eq ▸ h_ev

-- Substitution to prove n + 1 = m + 1 from n = m (explicit Eq.subst)
example (n m : Nat) (h : n = m) : n + 1 = m + 1 :=
  Eq.subst (motive := fun x => n + 1 = x + 1) h rfl

-- Same example using ▸ notation
example (n m : Nat) (h : n = m) : n + 1 = m + 1 :=
  h ▸ rfl
```

## Equality is an Equivalence Relation

A binary relation `R` on a type `α` is an **equivalence relation**
if it satisfies three properties:

- **Reflexive**: `R a a` for all `a` — everything is related to itself.
- **Symmetric**: `R a b → R b a` — the relation works in both directions.
- **Transitive**: `R a b → R b c → R a c` — the relation chains.

Equality is the prototypical equivalence relation. The `Eq` type
gives us reflexivity directly (`Eq.refl`), and from the single
constructor `refl` we can derive symmetry and transitivity. Our
goal for the next few sections is to build up these three
properties, along with the key proof tool — **substitution** — that
makes symmetry and transitivity provable.

### Symmetry

Given `h : a = b`, we want to prove `b = a`.
- The goal is `b = a`.
- We use `h ▸ rfl`: substitution rewrites the `b` in the goal
  to `a` (using `h : a = b`), giving the new goal `a = a`.
- `rfl` closes `a = a`.

```lean
-- Symmetry derived from refl + subst
theorem eq_symm {a b : α} (h : a = b) : b = a := by
  rw [h]
```

### Transitivity

Given `h1 : a = b` and `h2 : b = c`, we want to prove `a = c`.
- The goal is `a = c`.
- We use `h2 ▸ h1`: substitution rewrites the `c` in the goal
  to `b` (using `h2 : b = c`), giving the new goal `a = b`.
- `h1` is exactly a proof of `a = b`.

```lean
-- Transitivity derived from subst
theorem eq_trans {a b c : α} (h1 : a = b) (h2 : b = c) : a = c := by
  rw [h1, h2]
```

### The Complete Equivalence Relation

We have now derived all three equivalence relation properties
from just the introduction rule (`refl`) and the elimination
rule (`subst`/`▸`):

```lean
-- Reflexivity: directly from the constructor
theorem eq_refl (a : α) : a = a := rfl

-- Symmetry and transitivity: derived above
#check @eq_symm          -- a = b → b = a
#check @eq_trans         -- a = b → b = c → a = c
```

Lean's standard library provides these as `Eq.symm` and
`Eq.trans`. Now that we know where they come from, we can
use them freely.

```lean
#check @Eq.symm         -- {a b : α} → a = b → b = a
#check @Eq.trans        -- {a b c : α} → a = b → b = c → a = c

-- Using Eq.symm: flip an equation
example (h : 3 = 4) : 4 = 3 := h.symm

-- Using Eq.trans: chain two equalities
example (a b c : Nat) (h1 : a = b) (h2 : b = c) : a = c :=
  h1.trans h2
```

## Congruence and Equational Reasoning

### Congruence: `congrArg` and `congr`

If `a = b`, then `f a = f b` for any function `f`. This is
*congruence* — functions respect equality. Congruence is how
equalities propagate through expressions: if you know `x = y`,
you can conclude `f x = f y`, then `g (f x) = g (f y)`, and
so on — mechanically, one function application at a time.

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

### The `rw` Tactic

The `rw` (rewrite) tactic is the workhorse for equational
reasoning in tactic mode. Given a proof `h : a = b`, the
tactic `rw [h]` replaces all occurrences of `a` with `b`
in the goal. Use `rw [← h]` to rewrite right to left, and
`rw [h] at h'` to rewrite in a hypothesis.

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

-- Rewriting in a hypothesis
example (x y : Nat) (h : x = y) (h2 : x + 1 = 10) : y + 1 = 10 := by
  rw [h] at h2
  exact h2

-- Controlling direction
example (x y z : Nat) (h1 : x = y) (h2 : z = y) : x = z := by
  rw [h1, ← h2]
```

### Calculational Proofs with `calc`

For longer chains of equational reasoning, Lean provides `calc`
blocks. Each step states an equality and justifies it.

```lean
example (a b c d : Nat) (h1 : a = b) (h2 : b = c) (h3 : c = d) : a = d :=
  calc a = b := h1
    _ = c := h2
    _ = d := h3

-- A longer calculational proof
theorem add_eq_of_eq (a b c d : Nat)
    (hab : a = b) (hcd : c = d) : a + c = b + d :=
  calc a + c
    _ = b + c := by rw [hab]
    _ = b + d := by rw [hcd]
```

## Propositional Equality: Beyond Definitional

Definitional equality is *silent* — the kernel handles it without
you writing anything. But not all true equalities are definitional.
The distinction is important and sometimes surprising.

### When `rfl` Suffices: Right Zero

Look at the definition of `Nat.add`:

```
def Nat.add : Nat → Nat → Nat
  | a, Nat.zero   => a
  | a, Nat.succ b => Nat.succ (Nat.add a b)
```

The first defining equation says `a + 0 = a` — directly, by
definition. So `rfl` closes the goal, because the kernel can
reduce `n + 0` to `n` for any `n`.

```lean
#check Nat.add  -- right click and go to definition to see it

example (n : Nat) : n + 0 = n := rfl
example : ∀ (n : Nat), n + 0 = n := fun _ => rfl
```

### When `rfl` Fails: Left Zero

Now consider `0 + n = n`. There is no defining equation that
reduces `0 + n` to `n` — addition recurses on its *second*
argument, not its first. For a variable `n`, the kernel cannot
compute `0 + n` any further. The two sides are not definitionally
equal:

```lean
-- Uncomment to see the error: rfl cannot prove this
-- example (n : Nat) : 0 + n = n := rfl   -- TYPE ERROR
```

### Proof by Induction

To prove `0 + n = n`, we must *reason* — specifically, by
induction on `n`. Here is the proof as a recursive function:
given any `n`, it returns a proof of `0 + n = n`.

The inductive step uses `congrArg`, which says: if `a = b`
then `f a = f b` for any function `f`. The notation `(· + 1)` is
Lean shorthand for `fun x => x + 1`.

```lean
-- Recursive proof (= induction written as recursion)
def zero_add_proof : (n : Nat) → 0 + n = n
  | 0     => rfl                          -- 0 + 0 = 0 by definition
  | n' + 1 => congrArg (· + 1) (zero_add_proof n')
```

How does this work?

- **Base case** (`n = 0`): We need `0 + 0 = 0`. The kernel
  reduces `0 + 0` to `0`, so `rfl` suffices.
- **Inductive case** (`n = n' + 1`): We need `0 + (n' + 1) = n' + 1`.
  The recursive call `zero_add_proof n'` gives us `0 + n' = n'`
  (the induction hypothesis). Then `congrArg (· + 1)` adds
  `+ 1` to both sides, producing `(0 + n') + 1 = n' + 1`. The
  kernel accepts this because `a + (b + 1) = (a + b) + 1` is
  a defining equation of `+`.

The same proof in tactic style:

```lean
-- Tactic proof (same reasoning, different notation)
theorem zero_add (n : Nat) : 0 + n = n := by
  induction n with
  | zero => rfl
  | succ n' ih =>
    -- Goal: 0 + (n' + 1) = n' + 1
    -- ih : 0 + n' = n'
    rw [Nat.add_succ, ih]
```

This is *propositional equality* — a statement that is true but
requires an explicit proof. The recursive/inductive structure of
the proof mirrors the recursive structure of `Nat.add` itself.

We can also use the standard library's `Nat.add_comm`:

```lean
#check @Nat.add_comm    -- ∀ (n m : Nat), n + m = m + n

example (a b : Nat) : a + b = b + a := Nat.add_comm a b
```

## The Dependent Equality Problem

Everything above works smoothly because both sides of every
equation have the same type. But dependent types introduce a
fundamental new challenge: **when types depend on values, equal
values can have different types.**

This is the central intellectual problem of this section, and
it motivates everything that follows: `HEq`, `cast`, `transport`,
and `Eq.rec`.

### When Types Depend on Values

Consider length-indexed vectors — arrays that carry their
length in their type. Lean's standard library provides
`Vector α n`, defined as a thin wrapper around `Array`:

```
structure Vector (α : Type u) (n : Nat) where
  toArray : Array α
  size_toArray : toArray.size = n
```

The key feature is the index `n : Nat` in the type. A
`Vector Nat 3` is a *different type* from `Vector Nat 4` —
the length is part of the type, not just a runtime property.

For abstract `m`, a `Vector Nat m` and a `Vector Nat (0 + m)`
hold the same data, but they are *different types*. The kernel
cannot reduce `0 + m` when `m` is unknown — `Nat.add` pattern-
matches on the second argument, and an abstract `m` doesn't
match `.zero` or `.succ _`. So `0 + m` is not definitionally
equal to `m`. (Note: with *concrete* numerals like `0 + 3`,
Lean computes the result fully, so the issue only arises with
variable indices.)

Here's a length-unconstrained array. Note the type, `Array Nat`.

```lean
def arr1 : Array Nat := #[1,2,3,4,5]  -- any old array of Nat
#eval arr1[1]                       -- indexing, expect 2
```

Here's a length-constrained array, of type `Vector Nat 3`. Note
the `#v` notation for `Vector`, but just `#` for `Array`.
```lean
def v3a : Vector Nat 3 := #v[0,0,0]
def v3b : Vector Nat 3 := #v[0,0,1]
def v4  : Vector Nat 4 := #v[0,1,2,3]

#eval v4[2]


-- Recall the definition of Eq (=). Both args must be same type.

-- So we can compare two vectors of exactly the same type
#check v3a = v3b

-- We cannot compare two vectors of different types
-- #check v3a = v4

-- What about equality between Vectors of length n and (n + 0)?
#check fun (m : Nat) (v : Vector Nat (m + 0)) (w : Vector Nat m ) => v = w  -- ✓

-- What about a Vector of length m and one of length 0 + m?
-- #check fun (m : Nat) (v : Vector Nat m) (w : Vector Nat (0 + m)) => v = w  -- ✗ type mismatch
```

When index expressions are *definitionally equal*, they reduce
to the same normal form and Lean treats the types as identical.
But when they are not — as with `0 + m` vs `m` for abstract
`m` — the types are distinct even though they describe the same
data. This creates two problems.

1. **We cannot state `v = w`** when `v : Vector Nat (0 + m)`
   and `w : Vector Nat m` for abstract `m`, because `Eq`
   requires both sides to have the same type and `0 + m`
   does not reduce to `m`.
2. **We cannot use `v` where a `Vector Nat m` is expected**
   when `v : Vector Nat (0 + m)`, even though the data is
   the same — the types don't match.

Problem 1 (comparison) is solved by `HEq`. Problem 2 (use) is solved by `cast`
and `transport`.

### HEq: Equality Across Types

Recall Problem 1 above: we cannot even *state* `v = w` when
`v : Vector Nat (0 + m)` and `w : Vector Nat m`, because `Eq`
requires both sides to have the same type.

Heterogeneous equality solves this. Its definition differs from
`Eq` in one critical way — the two values may have *different*
types:

```
inductive HEq : {α : Sort u} → α → {β : Sort u} → β → Prop where
  | refl (a : α) : HEq a a
```

`HEq a b` (notation `a ≅ b`) says: `a` and `b` are equal, even
though they might live in different types `α` and `β`. The only
constructor is `refl`, which requires `α = β` and `a = b` — so
a proof can only *exist* when the types actually coincide. The
power of `HEq` is not that it proves more, but that it lets us
*state* the question when `Eq` cannot even be typed.

```lean
#check @HEq             -- HEq : α → β → Prop
#check @HEq.refl        -- HEq.refl : (a : α) → HEq a a
#print HEq
```

**When types match, `HEq` and `Eq` are interconvertible.** Any
`Eq` proof lifts to `HEq`, and any `HEq` proof whose sides have
the same type collapses back to `Eq`:

```lean
#check @heq_of_eq       -- a = b → HEq a b
#check @eq_of_heq       -- HEq a b → a = b  (when types match)

-- Lifting: Eq → HEq (types are both Nat, so this is trivial)
example (h : 3 = 3) : HEq 3 3 := heq_of_eq h

-- Collapsing: HEq → Eq (only works when types are definitionally equal)
example (h : HEq (2 : Nat) 2) : (2 : Nat) = 2 := eq_of_heq h
```

**Solving Problem 1: stating cross-type equality.** Ordinary
`Eq` cannot even type-check the comparison between a
`Vector Nat (0 + m)` and a `Vector Nat m` — the types differ.
`HEq` lets us state the question:

```lean
-- Ordinary Eq rejects this — the types differ for abstract m:
-- example (m : Nat) (v : Vector Nat (0 + m)) (w : Vector Nat m) : v = w := ...  -- TYPE ERROR

-- HEq accepts it — the question is well-formed even across types
example (m : Nat) (v : Vector Nat (0 + m)) (w : Vector Nat m) : Prop := HEq v w
```

Note: for *concrete* indices like `m = 3`, `0 + 3` reduces to
`3` and `Eq` works fine — the problem only manifests with
abstract indices:

```lean
-- Concrete indices: Eq works (0 + 3 reduces to 3)
example (v w : Vector Nat 3) : Prop := v = w

-- Abstract indices: only HEq can state the comparison
example (m : Nat) (v : Vector Nat (0 + m)) (w : Vector Nat m) : Prop := HEq v w
```

**`HEq` states the question but does not answer it.** To
actually *prove* such an equality or *use* a value at a
different type, we need `cast` and `transport`.

### Cast and Transport: Moving Values Between Types

Recall Problem 2: we cannot use a `Vector Nat (0 + m)` where
a `Vector Nat m` is expected. `HEq` lets us *state* that two
values across types are equal, but what we often need is to
*move* a value from one type to the other — a type-level
coercion justified by a proof.

The simplest tool is `cast`: given a proof that two types are
equal, convert a value from one to the other.

```lean
-- Uncomment to see the error: Vector Nat (0 + m) ≠ Vector Nat m
-- example (m : Nat) (v : Vector Nat (0 + m)) : Vector Nat m := v

#check @cast           -- cast : α = β → α → β

-- If we know (rfl : Nat = Nat), we can cast
example : cast rfl 42 = 42 := rfl
```

Here `cast rfl 42` says: given the proof `rfl : Nat = Nat`,
convert `42 : Nat` to type `Nat`. The proof is trivial (the
types are already the same), so the cast is a no-op — the
result equals `42` by `rfl`.

The interesting case is when the types differ only in their
index expressions, like `Vector Nat (0 + m)` vs `Vector Nat m`.
There, `cast` requires a proof that the two types are equal
— which in turn requires a proof that the indices are equal (e.g.,
`Nat.zero_add m : 0 + m = m`).

Closely related are `Eq.mp` and `Eq.mpr`:

- `Eq.mp  : α = β → α → β`  (forward: same as `cast`)
- `Eq.mpr : α = β → β → α`  (backward: cast in reverse)

```lean
#check @Eq.mp          -- α = β → α → β
#check @Eq.mpr         -- α = β → β → α

-- Eq.mp: given a proof that Vector Nat (0+m) = Vector Nat m,
-- move a value forward from Vector Nat (0+m) to Vector Nat m
-- @congrArg : ∀ {α : Sort u_1} {β : Sort u_2} {a₁ a₂ : α} (f : α → β), a₁ = a₂ → f a₁ = f a₂
example (m : Nat) (v : Vector Nat (0 + m)) : Vector Nat m :=
  Eq.mp (congrArg (Vector Nat) (Nat.zero_add m)) v

-- !!! Stop here an work to understand all aspects of this example

-- Eq.mpr: same proof, but move a value backward from Vector Nat m
-- to Vector Nat (0+m)
example (m : Nat) (w : Vector Nat m) : Vector Nat (0 + m) :=
  Eq.mpr (congrArg (Vector Nat) (Nat.zero_add m)) w

-- !!! Stop here an work to understand all aspects of this example
```

For indexed families like `Vector` we need something slightly
more structured: **transport**. Given a type family, `motive,`
indexed by some value, transport moves data from one index to
another along an equality proof.

```lean
-- Transport: move a value along an equality of indices
def transport
  {α : Sort u}
  {a b : α}
  (motive : α → Sort v)
  (h : a = b)
  (x : motive a) :
  motive b :=
  h ▸ x

-- Transport a vector from length n to length m
def Vector.cast
  {α : Type}
  {n m : Nat}
  (h : n = m)
  (v : Vector α n) :
  Vector α m :=
  transport (Vector α) h v

-- !!! Stop here an work to understand all aspects of this example
```

### Exercises: Cast and Transport Basics

Replace each `sorry` with a proof.

```lean
-- Exercise: use cast with a trivial type equality proof
-- Hint: if the types are the same, what proof do you need?
example : cast rfl "hello" = "hello" := sorry

-- Exercise: use Eq.mp to move a value from Nat to Nat
-- Hint: what proof shows Nat = Nat?
example (n : Nat) : Eq.mp rfl n = n := sorry

-- Exercise: use transport to move a value along rfl
-- Hint: transport motive rfl x = ?
example (v : Vector Nat 3) : transport (Vector Nat) rfl v = v := sorry

-- Exercise: build a type equality proof from an index equality proof
-- Hint: if h : a = b, then congrArg f h : f a = f b
example (m : Nat) (h : 0 + m = m) : Vector Nat (0 + m) = Vector Nat m :=
  sorry

-- Exercise: cast a vector using a proof you construct
-- Hint: combine cast, congrArg, and Nat.add_zero
example (n : Nat) (v : Vector Nat (n + 0)) : Vector Nat n :=
  sorry
```

Now we can solve the dependent cast problem: a `Vector α (0 + n)`
can be converted to a `Vector α n` using the proof that `0 + n = n`.

```lean
-- This does NOT type-check without a cast:
-- example (n : Nat) (v : Vector Nat (0 + n)) : Vector Nat n := v   -- ERROR

/-
def transport
  {α : Sort u}
  {a b : α}
  (motive : α → Sort v)
  (h : a = b)
  (x : motive a) :
  motive b :=
  h ▸ x
  -/

-- Transport bridges the gap
def Vector.zeroAddCast
  {α : Type}
  {n : Nat}
  (v : Vector α (0 + n)) :
  Vector α n :=
  transport (Vector α) (Nat.zero_add n) v

-- And the reverse direction
def Vector.zeroAddCast'
  {α : Type}
  {n : Nat}
  (v : Vector α n) :
  Vector α (0 + n) :=
  transport (Vector α) (Nat.zero_add n).symm v

-- All of these are equivalent ways to cast:
example (n : Nat) (h : 0 + n = n) (v : Vector Nat (0 + n)) : Vector Nat n :=
  cast (congrArg (Vector Nat) h) v

example (n : Nat) (h : 0 + n = n) (v : Vector Nat (0 + n)) : Vector Nat n :=
  h ▸ v

example (n : Nat) (h : 0 + n = n) (v : Vector Nat (0 + n)) : Vector Nat n :=
  transport (Vector Nat) h v
```

### Transport Preserves Identity

A key property: casting does not change the "value" — it only
changes the type annotation. This is captured precisely by `HEq`:
the transported value is heterogeneously equal to the original.

```lean
-- Transport by rfl is the identity
theorem transport_rfl
  {α : Sort u}
  {a : α}
  (motive : α → Sort v)
  (x : motive a) :
  transport motive rfl x = x := rfl
```

When the index equality proof is `rfl` (the source and target
indices are definitionally equal), transport does nothing at
all — `transport motive rfl x` is definitionally equal to `x`.
This is the base case: casting along a trivial proof is the
identity.

But what about non-trivial proofs, where the source and target
types genuinely differ (like `Vector Nat (0 + m)` vs
`Vector Nat m`)? The transported value has a *different type*,
so ordinary `Eq` cannot even state that it equals the original.
This is exactly where `HEq` earns its keep:

```lean
-- Transport preserves value up to HEq
theorem transport_heq {α : Sort u} {a b : α}
    (motive : α → Sort v) (h : a = b) (x : motive a) :
    HEq (transport motive h x) x := by
  subst h
  exact HEq.refl x
```

The proof works by `subst h`: since `h : a = b`, substituting
turns the goal into `HEq (transport motive rfl x) x`, which
reduces to `HEq x x` by `transport_rfl`, and `HEq.refl`
closes it. The result: transport changes the type label but
the underlying data is unchanged — the original and the
transported value are heterogeneously equal.

Lean's standard library provides the same fact for `cast`:

```lean
#check @cast_heq       -- (h : α = β) → (a : α) → HEq (cast h a) a
```

### Eq.rec: The Mechanism Underneath

All of the above — `cast`, `▸`, `subst`, `transport` — are built
on a single primitive: **`Eq.rec`**, the recursor (eliminator) for
the equality type.

Every inductive type in Lean comes with a recursor. For `Eq`,
the recursor says: if you can produce something when the two
sides are the same (the `refl` case), then you can produce it
whenever the two sides are provably equal.

```lean
#check @Eq.rec
-- @Eq.rec : {α : Sort u} →
--   {a : α} →
--   {motive : (b : α) → a = b → Sort v} →
--   motive a rfl →
--   {b : α} →
--   (h : a = b) →
--   motive b h
```

Read the type carefully:
- `a : α` is a fixed value.
- `motive` is a dependent function: given any `b` and a proof
  that `a = b`, it returns a *type*.
- You supply a value of `motive a rfl` — the case where `b` is
  just `a` and the proof is `rfl`.
- Given any `b` and proof `h : a = b`, you get back `motive b h`.

The equality proof `h` "transports" your value from the `a` fiber
to the `b` fiber of the motive. Here are two examples with all
arguments written explicitly:

```lean
-- Symmetry via Eq.rec
-- motive: fun (x : Nat) (_ : a = x) => x = a
-- base case (x = a, proof = rfl): need a = a, which is rfl
-- result: given h : a = b, get b = a
example (a b : Nat) (h : a = b) : b = a :=
  @Eq.rec Nat a (fun x _ => x = a) rfl b h

-- Transporting a predicate via Eq.rec
-- motive: fun (x : Nat) (_ : a = x) => x % 2 = 1
-- base case: a % 2 = 1, which is hodd
-- result: given h : a = b, get b % 2 = 1
example (a b : Nat) (h : a = b) (hodd : a % 2 = 1) : b % 2 = 1 :=
  @Eq.rec Nat a (fun x _ => x % 2 = 1) hodd b h
```

In practice, the motive often does not depend on the proof `h`
itself — only on `b`. Lean provides `Eq.ndrec` (non-dependent
rec) for this simpler case:

```lean
#check @Eq.ndrec
-- @Eq.ndrec : {α : Sort u} →
--   {a : α} →
--   {motive : α → Sort v} →
--   motive a →
--   {b : α} →
--   a = b →
--   motive b

-- Symmetry via Eq.ndrec
example (a b : Nat) (h : a = b) : b = a :=
  @Eq.ndrec Nat a (fun x => x = a) rfl b h

-- Congruence via Eq.ndrec
example (a b : Nat) (h : a = b) : a + 1 = b + 1 :=
  @Eq.ndrec Nat a (fun x => a + 1 = x + 1) rfl b h
```

### Summary of the Dependent Equality Toolkit

| Tool | What it does |
|---|---|
| `HEq` | State equality between values of different types |
| `cast` | Convert a value when the types are provably equal |
| `Eq.mp` / `Eq.mpr` | Forward/backward cast between equal types |
| `transport` (ours) | Move data along an index equality in a type family |
| `▸` / `subst` | Term-mode rewriting — Lean infers the motive |
| `Eq.rec` | The primitive eliminator — fully dependent motive |
| `Eq.ndrec` | Non-dependent version — motive ignores the proof |

In practice, you'll most often use `▸` or `subst` in term mode,
and `rw`/`simp` in tactic mode. Reaching for `Eq.rec` directly
is rare but sometimes necessary when Lean cannot infer the motive.

---

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

They are connected, but the connection requires a *lawful* `BEq`
instance — one that agrees with propositional equality. For
Lean's built-in types (Nat, String, etc.) this holds: `(a == b)
= true ↔ a = b`.

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
For symbolic (variable-containing) goals, `decide` cannot help —
you need `rfl`, `rw`, or induction.

```lean
example : 10 * 10 = 100 := by decide
example : "abc".length = 3 := by decide
example : ¬ (7 = 8) := by decide
```

## Summary

| Concept | Type/Tactic | Purpose |
|---|---|---|
| Definitional equality | (kernel judgment) | Interconvertible by computation/unfolding |
| `Eq` / `rfl` | `a = b`, `Eq.refl` | Propositional equality |
| `Eq.subst` / `▸` | `a = b → P a → P b` | Substitute equals for equals |
| `Eq.symm` | `a = b → b = a` | Flip an equation |
| `Eq.trans` | `a = b → b = c → a = c` | Chain equations |
| `congrArg` | `a = b → f a = f b` | Functions respect equality |
| `rw` | tactic | Rewrite in goal or hypothesis |
| `calc` | proof block | Chain of equational steps |
| `HEq` | `HEq a b` | Equality across types |
| `cast` / `transport` | type conversion | Move values between equal types |
| `Eq.rec` | eliminator | The primitive underneath all equality reasoning |
| `DecidableEq` | typeclass | Runtime equality checking |
| `BEq` / `==` | typeclass | Boolean equality for programs |

## Additional Resources

- [CS1: Programming, Certified](https://kevinsullivan.github.io/Lean4CS1/) —
  An introductory programming course in Lean 4 that integrates
  formal specification and automated proof verification from day
  one, teaching data types, functions, recursion, and the
  Curry-Howard correspondence.


## Exercises

Replace each `sorry` with a proof (or state that you
can't and if you can, explain that that's because it's
impossible). The exercises are grouped by topic and
increase in difficulty within each group.

### Equational Reasoning

```lean
-- Exercise 1: Chain two equalities and apply a function.
-- Hint: combine Eq.trans and congrArg (or use rw/calc).
theorem ex_chain (a b c : Nat) (h1 : a = b) (h2 : b = c) :
    a + 1 = c + 1 := sorry

-- Exercise 2: Prove using a calc block with at least 3 steps.
theorem ex_calc (a b c d : Nat)
    (h1 : a = b + 1) (h2 : b = c) (h3 : c = d + 2) :
    a = d + 3 := sorry

-- Exercise 3: Prove by induction on m.
-- Hint: the inductive step needs congrArg or rw with the IH.
theorem ex_succ_add (n m : Nat) : (n + 1) + m = (n + m) + 1 := sorry
```

### Dependent Equality

```lean
-- Exercise 4: Why does this fail? Fix it by providing a cast.
-- (Uncomment and replace sorry with a working term.)
-- def ex_stuck (n : Nat) (v : Vector Nat (0 + n)) : Vector Nat n := v
def ex_cast (n : Nat) (v : Vector Nat (0 + n)) : Vector Nat n := sorry

-- Exercise 5: State and prove that transport along rfl is identity.
theorem ex_transport_rfl (n : Nat) (v : Vector Nat n) :
    transport (Vector Nat) rfl v = v := sorry

-- Exercise 6: Show that transporting preserves value (HEq).
-- Hint: what tactic eliminates an equality hypothesis from context?
theorem ex_transport_heq (n m : Nat) (h : n = m) (v : Vector Nat n) :
    HEq (transport (Vector Nat) h v) v := sorry

-- Exercise 7: Round-trip — transport forward then back = identity.
-- Hint: after subst, both transports become transport _ rfl.
theorem ex_round_trip (n m : Nat) (h : n = m) (v : Vector Nat n) :
    transport (Vector Nat) h.symm (transport (Vector Nat) h v) = v := sorry

-- Exercise 8: Build Eq.mp from transport.
-- Show that Eq.mp is just transport with motive = id.
theorem ex_mp_is_transport (α β : Type) (h : α = β) (x : α) :
    Eq.mp h x = transport id h x := sorry

end Content.B07_Equality.chapters.CS6501_Equality
```
