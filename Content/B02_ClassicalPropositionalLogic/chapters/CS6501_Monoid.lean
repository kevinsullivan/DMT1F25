import Mathlib.Algebra.Group.Defs
import Mathlib.Algebra.Group.Nat.Defs

/- @@@
# Overloaded Structures: I. Monoid

<!-- toc -->

In the NatList chapter we defined a type (Nat), operations
on it (add, mul), and tested them. But we never *proved*
that our operations have the properties we expect. For
example, we expect addition to be associative, and we
expect zero to be an identity element. How do we state
and enforce such requirements?

The answer is *algebraic structures*. An algebraic structure
bundles together a type, operations, and proofs that those
operations satisfy specified laws. A *monoid* is one of the
simplest and most pervasive such structures.

## What is a Monoid?

A monoid is a triple: a type of objects (the *carrier set*),
a binary operation on those objects, and a distinguished
element that serves as an identity for the operation. These
three components must satisfy two laws:

- **Associativity**: for all a, b, c, we have (a * b) * c = a * (b * c)
- **Identity**: there exists an element e such that e * a = a and a * e = a

Familiar examples include (Nat, +, 0) and (Nat, *, 1).
Both are monoids. Strings under concatenation with the
empty string form a monoid. Lists under append with the
empty list form a monoid.
@@@ -/

namespace Content.B02_ClassicalPropositionalLogic.chapters.monoid

/- @@@
## Mathlib's Additive Monoid

Lean's Mathlib library defines `AddMonoid` as a typeclass.
A typeclass is a way of associating structure (operations,
laws) with a type. To understand `AddMonoid`, we'll read
its definition top-down, starting from the top-level class
and working down through its component parts.

Here is the class, lightly reformatted.

```
class AddMonoid (M : Type u) extends AddSemigroup M, AddZeroClass M where
  protected nsmul : ℕ → M → M
  protected nsmul_zero : ∀ x, nsmul 0 x = 0
  protected nsmul_succ : ∀ (n : ℕ) (x), nsmul (n + 1) x = nsmul n x + x
```

An AddMonoid extends two simpler structures, AddSemigroup
and AddZeroClass, and adds *nsmul* (natural-number scalar
multiplication: repeating the addition n times). The nsmul
fields have default proofs, so we typically don't need to
supply them ourselves.
@@@ -/

#check AddMonoid

/- @@@
### AddSemigroup: A Type with Associative Addition

An AddSemigroup requires a binary addition operation
and a proof that it is associative.

```
class AddSemigroup (G : Type u) extends Add G where
  protected add_assoc : ∀ a b c : G, a + b + c = a + (b + c)
```
@@@ -/

#check AddSemigroup

/- @@@
### Add: A Type with a Binary Operation

At the bottom of the hierarchy, Add simply declares that
a type has a binary operation called *add*, written `+`.

```
class Add (α : Type u) where
  add : α → α → α
```
@@@ -/

#check Add

/- @@@
### AddZeroClass: A Type with Zero as Identity

AddZeroClass requires a zero element and proofs that it
is both a left and a right identity for addition.

```
class AddZeroClass (M : Type u) extends Zero M, Add M where
  protected zero_add : ∀ a : M, 0 + a = a
  protected add_zero : ∀ a : M, a + 0 = a
```

It extends two even simpler classes: Zero (which provides
the constant `0`) and Add (which provides `+`).
@@@ -/

#check AddZeroClass

/- @@@
### Zero and Add: The Primitives

Zero simply provides a distinguished element called `0`.
Add provides the binary `+` operation. These are the raw
materials from which all the richer structures are built.
@@@ -/

#check Zero
#check Add

/- @@@
### Summary of Requirements

Putting it all together, to construct an AddMonoid for a
type M we need to provide:

- a binary operation, + : M → M → M
- a zero element, 0 : M
- a proof that 0 is a left identity: ∀ a, 0 + a = a
- a proof that 0 is a right identity: ∀ a, a + 0 = a
- a proof of associativity: ∀ a b c, (a + b) + c = a + (b + c)
- a definition of nsmul (usually derived automatically)
@@@ -/

/- @@@
## Example: Duration as a Monoid

Let's build a monoid from scratch. Consider durations
on a three-position clock: zero hours, one hour, or two
hours. Addition of durations wraps around modulo three:
one + two = zero, two + two = one, and so on.

This is ℤ₃, the integers modulo 3, under addition. It
is an additive monoid with identity element *zero*.
@@@ -/

inductive Duration where
| zero
| one
| two
deriving Repr, BEq, DecidableEq

open Duration

/- @@@
### Addition of Durations

We define addition by case analysis on both arguments.
There are nine cases, one for each pair of values. The
pattern is modular arithmetic: the sum wraps around
when it reaches three.
@@@ -/

def durAdd : Duration → Duration → Duration
| zero, d => d
| d, zero => d
| one, one => two
| one, two => zero
| two, one => zero
| two, two => one

#eval durAdd one two    -- zero
#eval durAdd two two    -- one

/- @@@
### Building the Monoid Instance

To register Duration as an AddMonoid with Lean's typeclass
system, we need to provide instances for each layer of the
hierarchy: Add, Zero, AddSemigroup, AddZeroClass, and finally
AddMonoid.
@@@ -/

instance : Add Duration where
  add := durAdd

instance : Zero Duration where
  zero := Duration.zero

/- @@@
Now we can write `a + b` and `0` for Duration values.
@@@ -/

#eval (one + two : Duration)    -- zero
#eval (zero + one : Duration)   -- one

/- @@@
Next we need a proof that durAdd is associative. Because
Duration has only three values, we can prove this by having
Lean exhaust all cases. For associativity, there are 3³ = 27
combinations to check. The *cases* tactic splits on each
constructor; *rfl* closes each goal by computation.
@@@ -/

instance : AddSemigroup Duration where
  add_assoc := by intro a b c; cases a <;> cases b <;> cases c <;> rfl

instance : AddZeroClass Duration where
  zero_add := by intro a; cases a <;> rfl
  add_zero := by intro a; cases a <;> rfl

instance : AddMonoid Duration where
  nsmul := nsmulRec
  nsmul_zero := by intro x; rfl
  nsmul_succ := by intro n x; rfl

/- @@@
Duration is now a registered AddMonoid. This means that
any general theorem or function in Mathlib that works for
an arbitrary AddMonoid will now work for Duration.

### Verification

We can verify a few properties to confirm that our monoid
behaves as expected.
@@@ -/

#eval (one + zero : Duration)     -- one (right identity)
#eval (zero + two : Duration)     -- two (left identity)
#eval (one + one + one : Duration) -- zero (wraps around)

-- Associativity in action
#eval ((one + two) + two : Duration)   -- two
#eval (one + (two + two) : Duration)   -- two

/- @@@
## A Familiar Monoid: Nat under Addition

The natural numbers under addition with identity zero
form a monoid. Lean and Mathlib already know this, so
Nat already has an AddMonoid instance. We can verify it.
@@@ -/

#check (inferInstance : AddMonoid Nat)

/- @@@
## Why Algebraic Structures Matter

Without algebraic structures, we'd have types, and we'd
have functions on those types, and nothing to connect the
two. We could define *myAdd* on Nat and have no assurance
that it's associative or that zero is its identity. A
bug in our implementation would go undetected.

Algebraic structures solve this problem. An AddMonoid
instance for a type M is not just a claim that M has
addition and a zero — it is a *proof* that those operations
satisfy the monoid laws. Once we have such a proof, any
downstream code that relies on associativity or identity
can trust these properties unconditionally.

This is the shift from *testing* to *proving*. Tests check
finitely many cases. Proofs cover them all.
@@@ -/

end Content.B02_ClassicalPropositionalLogic.chapters.monoid
