# Controlling Unwrapping and Reduction

<!-- toc -->

By this point in the course you have written enough proofs to
have noticed a recurring pattern: the goal *looks* almost right,
but Lean refuses to close it. You see two terms that you know
are "the same," yet `rfl` fails, `exact` fails, and even
`simp` flounders. The trouble is almost always the same — Lean
is comparing the two terms at a level of *unfolding* or
*reduction* that does not match where the equality actually
lives.

The cure is a small family of tactics that give you fine-grained
control over how much Lean is willing to look inside a term:
`ext`, `funext`, `congr`, `unfold`, `delta`, `change`, `show`,
and the various `simp`-with-unfolding variants. They are all
about the same question:

> *How deeply should Lean tear open these terms before deciding
> whether they are equal?*

This chapter is a survey of those tactics, the situations they
address, and the troubles they can cause when used carelessly.
We close with the trickiest case of all: equalities that span
casts and coercions, where unwrapping is no longer optional and
must be carried out with care.

```lean
namespace Content.B08_Wrap.chapters.CS6501_UnwrappingAndReduction
```

## The Core Question: How Far Should Lean Reduce?

Every equality goal in Lean lives at some level of reduction.
At one extreme, two terms are *syntactically* identical — the
parser produces the same tree. At the other extreme, two terms
are equal only after arbitrarily deep unfolding, computation,
beta/iota/delta reduction, and possibly an appeal to function
extensionality or propositional equality.

The job of the proof author is to *meet Lean halfway*: unfold
enough that the kernel sees the equality, but not so much that
the goal explodes into an unreadable mess. The tactics in this
chapter are the dials you turn to find that midpoint.

## Extensional Tactics: `ext` and `funext`

### Function Extensionality

Two functions `f g : α → β` are *extensionally* equal when
`∀ x, f x = g x`. In Lean's type theory this is *not* a
definitional equality — it is a propositional fact that must
be invoked explicitly via `funext`.

```lean
example (f g : Nat → Nat) (h : ∀ x, f x = g x) : f = g := by
  funext x
  exact h x
```

The `funext` tactic takes a goal `f = g` between functions and
reduces it to a goal `f x = g x` for a fresh variable `x`. It
is the canonical way to "go under the binder."

### The General `ext` Tactic

`ext` is `funext`'s cousin for *any* type with a registered
extensionality lemma: sets, subtypes, structures, finsets,
quotients, and so on. It walks the goal and applies the
appropriate `ext`-lemma at each level.

```lean
-- Equality of records reduces to equality of fields
@[ext] structure Pair where
  fst : Nat
  snd : Nat

example (p q : Pair) (h1 : p.fst = q.fst) (h2 : p.snd = q.snd) : p = q := by
  ext
  · exact h1
  · exact h2
```

### Where `ext` Causes Trouble

`ext` is powerful but indiscriminate. The most common pitfalls:

- **Premature unwrapping.** Applying `ext` before you've
  simplified the structure can produce a goal that is harder,
  not easier, to close. Once you have unwrapped to a per-element
  goal, you've lost the algebraic shape of the original.
- **Wrong extensionality lemma.** For nested types (a `Set`
  of `Set`s, a function returning a structure), `ext` may pick
  the outermost lemma when you wanted the inner one. Use `ext x y`
  to control depth, or apply specific lemmas by name.
- **Loss of definitional equality.** After `ext`, the two sides
  are no longer the *same* function — they are *pointwise* equal.
  Tactics that relied on definitional equality (like `rfl` against
  a folded term) may now fail.

## Congruence: `congr` and `congr!`

`congr` reduces an equality `f a b = f c d` to the component
goals `a = c` and `b = d`. It is the structural counterpart to
`ext`: instead of going under a binder, it goes under a
constructor or function symbol.

```lean
example (a b c d : Nat) (hac : a = c) (hbd : b = d) :
    (a, b) = (c, d) := by
  congr
```

### Where `congr` Causes Trouble

- **Over-eager descent.** Plain `congr` will keep splitting until
  it cannot anymore, sometimes producing a swarm of trivial
  subgoals or, worse, dependent subgoals it cannot state cleanly.
  Use `congr 1` (or `2`, `3`, …) to bound the depth.
- **Dependent arguments.** When later arguments depend on earlier
  ones, `congr` may produce `HEq` subgoals instead of `Eq`.
  These are harder to close and often require a `subst` or a
  cast manipulation.
- **`congr!` is more aggressive.** It uses extensionality lemmas
  and does more cleanup, but it can also discharge subgoals you
  wanted to inspect, hiding mistakes.

## Definitional Unwrapping: `unfold`, `delta`, `show`, `change`

These tactics rewrite the goal at a level *below* the propositional
layer. They do not change what is provable — they change what the
goal *looks like* so that subsequent tactics can fire.

### `unfold`

`unfold f` replaces occurrences of `f` with its definition,
performing the standard reductions afterward. This is your
primary tool when `rfl` should work but doesn't because Lean
isn't reducing `f` on its own.

```lean
def myDouble (n : Nat) : Nat := n + n

example (n : Nat) : myDouble n = n + n := by
  unfold myDouble
  rfl
```

### `change` and `show`

`change e` (and the term-mode `show e`) replaces the goal with
`e` *provided* the new goal is definitionally equal to the old
one. It is a controlled, surgical alternative to `unfold`: you
state exactly the form you want, and Lean checks the conversion.

This is invaluable when `unfold` would expose too much, or when
you want to *re-fold* a term after partial reduction.

```lean
example (n : Nat) : myDouble n = 2 * n := by
  change n + n = 2 * n
  omega
```

### Where Unwrapping Causes Trouble

- **Irreversible unfolding.** Once you `unfold f`, the term `f`
  is gone from the goal. If you needed it later as a black box —
  say, to apply a lemma about `f` — you must reintroduce it with
  `change` or by proving it back. The convention in this codebase
  is `unfold` rather than `simp` precisely because `unfold` is
  surgical: you control exactly what is exposed.
- **Reducible vs. irreducible definitions.** Some definitions
  are marked `@[reducible]` and unfold automatically; others are
  `@[irreducible]` and resist unfolding. A goal that "should be
  `rfl`" may be blocked by an irreducible definition you didn't
  write yourself.
- **Unfolding past the abstraction barrier.** Library code is
  often written so that the *interface* (the lemmas about `f`)
  is what you should use, not `f`'s implementation. Aggressive
  `unfold` defeats the abstraction and makes proofs fragile —
  they break when the implementation changes.
- **`simp` versus `unfold`.** `simp [f]` will unfold `f` *and*
  apply every other simp lemma in scope, which often does too
  much. Prefer `unfold f` when you want exactly that one step.

## A Summary of Problem Cases

The tactics above cover most situations, but each comes with
characteristic failure modes. Here is a catalogue, ordered
roughly from easiest to hardest.

### 1. The Goal Is Already True, but `rfl` Fails

Almost always a missing reduction. Try `unfold` on the outermost
defined name, or `change` to a form that exposes the computation.
If a binder is involved, you may need `funext` first.

### 2. `ext` Produced a Goal You Cannot Close

You went too deep. Restart and apply `ext x` for a single binder,
or apply a specific extensionality lemma by name. Ask yourself
whether the original equality really needed extensional
unwrapping at all — sometimes the algebraic form admits a
direct proof.

### 3. `congr` Produced Spurious or Dependent Subgoals

Replace `congr` with `congr 1` (or 2). If you get an `HEq` goal,
you likely have a *dependent* argument. The fix is usually to
prove the index equality first and `subst` it before descending.

### 4. `unfold` Exposed Too Much

Use `change` to re-fold the parts you didn't want exposed, or
unfold a more specific definition. If the unfolded form is
unavoidable, consider whether a lemma about the definition would
be cleaner than reasoning at the implementation level.

### 5. Irreducible or Opaque Definitions

If `unfold` does nothing on a name `f`, check whether `f` is
`@[irreducible]`, defined with `opaque`, or an `axiom`. The
fix is not to force unfolding (which usually isn't possible
anyway) but to find the API lemma that lets you reason about `f`
abstractly.

### 6. Casts and Coercions

The hardest case, and the subject of the next section.

## Casts and Coercions: When Unwrapping Cannot Be Avoided

A *cast* in Lean is a term that transports a value of one type
to a (provably equal) other type:

- `Eq.mp : α = β → α → β` — transport along a propositional type
  equality.
- `cast : α = β → α → β` — the same, written differently.
- `h ▸ x` — rewrite `x` along an equality `h`.

A *coercion* is an automatically inserted cast, written `↑x`
or simply elided. Coercions appear when Lean expects type `β`
and is given a value of type `α`, and an instance
`Coe α β` (or `CoeHead`, `CoeTC`, `CoeFun`, `CoeSort`) is in
scope.

Both casts and coercions introduce a wrapper around the value
that carries no computational content but is *visible to the
type checker* and to syntactic matching. This is where
unwrapping and reduction get genuinely hard.

### Why Casts Block `rfl`

A cast `cast h x` is *not* definitionally equal to `x`, even
when `h` is `rfl`. The kernel will reduce `cast rfl x` to `x`,
but a cast along a non-`rfl` equality remains stuck — there is
no computation rule that erases it. You must either:

1. Substitute the equality away with `subst h`, eliminating the
   need for the cast.
2. Rewrite using a lemma like `cast_cast`, `cast_eq`, or one of
   the `Eq.mpr_*` family, until the casts cancel or align.
3. Drop down to `HEq` and use heterogeneous-equality machinery,
   then climb back up to `Eq` at the end.

### Why Coercions Block Pattern Matching

When you write `(n : ℤ)` and `n : ℕ`, Lean inserts `↑n` —
typically `Int.ofNat n` or `Nat.cast n`. A goal like
`(↑n : ℤ) + 0 = ↑n` is not `rfl` because the coercion is a
function call, and `+ 0` on `ℤ` is not the same definition as
`+ 0` on `ℕ`.

Standard remedies:

- `push_cast` — pushes coercions inward, toward the leaves.
- `norm_cast` — normalizes a goal by canceling and aligning
  coercions; closes goals that are "cast-trivial."
- `simp [Nat.cast_zero, Int.ofNat_add, …]` — when the cast lemmas
  you need are not in `norm_cast`'s default set.

### The Trouble Casts Cause

- **Visible noise.** A goal cluttered with `↑` and `cast _` is
  hard to read; it is easy to miss that the goal is, in fact,
  trivial after normalization.
- **Lost rewrites.** A `rw` that should fire often doesn't,
  because the LHS of the rewrite lemma matches the *uncoerced*
  form while the goal has a coercion in the way. `push_cast` or
  `norm_cast` first, then `rw`.
- **Dependent casts.** When a cast appears in the *type* of a
  later argument (e.g., `Vector α (n + 0)` vs. `Vector α n`),
  removing it requires propagating the equality through the
  dependent context — exactly the situation `HEq` was designed
  for, and exactly the situation that motivates `subst` over
  `rw`.
- **Coercion diamonds.** Multiple coercion paths from `α` to `γ`
  (e.g., `α → β → γ` and `α → γ` directly) can produce two
  syntactically different but propositionally equal results.
  Lean picks one path during elaboration; if a lemma proved the
  other path, you have a frustrating mismatch that no amount of
  `unfold` will fix without an explicit cast lemma.

## A Working Discipline

The recurring lesson is that *control* matters more than power.
A precise `change` beats a sweeping `simp`. A bounded `congr 1`
beats an unbounded `congr`. A targeted `unfold f` beats `simp [f]`.
And when casts appear, reach for `norm_cast`/`push_cast` *before*
trying to muscle through with `rw` or `rfl`.

The unifying mental model:

> Every goal lives at some level of reduction. Your job is to
> bring the goal and your tactics to the *same* level — neither
> more abstract nor more unfolded than necessary.

The next section gives exercises that exhibit each problem case
above. Work them in order; the difficulty curve mirrors the
catalogue.

## Exercises

These are intentionally left as `sorry` for now and will be
filled in as the chapter develops.

```lean
-- Exercise 1: Close with `funext` and an appropriate per-element argument.
example (f g : Nat → Nat) (h : ∀ x, f x = g x) : (fun x => f x + 1) = (fun x => g x + 1) := by
  sorry

-- Exercise 2: A goal that fails with `rfl` until you `unfold`.
def myId (n : Nat) : Nat := n
example (n : Nat) : myId n = n := by
  sorry

-- Exercise 3: Use `change` to re-fold after partial reduction.
example (n : Nat) : myDouble n = 2 * n := by
  sorry

-- Exercise 4: A `congr` that requires bounding the depth.
example (a b : Nat) (h : a = b) : (a + 1, a * 2) = (b + 1, b * 2) := by
  sorry

-- Exercise 5: A coercion that blocks `rfl`; use `norm_cast` or `push_cast`.
example (n : Nat) : ((n : Int) + 0) = (n : Int) := by
  sorry

-- Exercise 6: A cast that must be eliminated by `subst`.
example (n m : Nat) (h : n = m) (v : Vector Nat n) :
    HEq (h ▸ v) v := by
  sorry

end Content.B08_Wrap.chapters.CS6501_UnwrappingAndReduction
```
