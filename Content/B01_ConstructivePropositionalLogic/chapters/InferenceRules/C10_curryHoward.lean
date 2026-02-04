import Mathlib.Logic.Equiv.Defs

namespace Content.book1lib.chapters.C10_curryHoward

/- @@@
# Product and Sum Types Mirror And and Or
@@@ -/

-- data types
#check 3
#check Nat
def x : Nat := 3

-- function types
#check String → Bool
def f : String → Bool := fun _ => true

/- @@@
## Product Types

Product types are types of *ordered pairs*.
By this term we simply mean the kinds of ordered
pairs one used in high school algebra, e.g., for
the coordinates of a point on a graph of some
function on the Cartesian plane, e.g., (3, 4).

The pair, *(3, 4)* has two elements both of some
numeric type, e.g., Nat. In high school algebra
they'd be *real* numbers. However, we can have
ordered pairs with first and second elements
of arbitrary types. Here's an ordered pair with
a string as its first element and a Boolean as
its second argument: *("Hello", true).

We say that such values are values of *product*
types (a general, not a Lean-specific, concept).

### Introduction

To make an ordered pair, one uses the constructor,
*Prod.mk*.  Lean also provides ordinary ordered
pair notation. The pair ("Hello", true), for example
is a value of type *Prod String Bool*. Lean provides
a notation for product types: here it's String × Bool.
You can pronounce that as String times Bool.

Here's the definition of Lean's Prod type.
@@@ -/

structure Prod (α : Type u) (β : Type v) where
  mk ::
  fst : α
  snd : β

#check ("Hello", true)

/- @@@
### Elimination / Destructuring / Projection

Given a value of a product type one has two elimination
rules. Their names are just *fst* and *snd* (thanks to
the *structure* construct in Lean). And you use them
just as you would *And.left* and *And.right*.
@@@ -/

#eval ("Hello", true).fst
#eval ("Hello", true).snd

/- @@@
### Functions From and To Product Types

Given product types, we can of course
define function types that take and return pairs
as values. Here's the type of function taking a
string-Boolean pair as an argument and returning
that pair in reverse order.
@@@ -/

#check (String × Bool) → (Bool × String)

/- @@@
Given a String-Bool ordered pair, can you return
a Bool-String ordered pair? Yes. See the following
function definition. It "destructures" the incoming
pair as (l, r), then it constructs and return a new
ordered pair, (r, l).
@@@ -/

-- formerly called c
def swap : (String × Bool) → (Bool × String) :=
  fun ((l, r) : String × Bool) => (r, l)

/- @@@
Note that we pattern match with new syntax
here, destructuring the incoming argument as
(l, r) right in the declaration of the argument
type. We could have used *h : String × Bool*,
and that'd be fine, but then we'd need to use
*match h with ...* explicitly to destructure
it; or we could refer to *h.fst* and *h.snd*.
This style of destructuring is commonplace in
languages such as Javascript and others.
@@@ -/

-- It computes
#eval swap ("Hi", true)

/- @@@
Here's a version of the swap function that
abstracts from the specific String and Bool
types to any types, α and β. We thus have
this polynorphic swap function.
@@@ -/

def swap' {α β : Type} : (α × β) → (β × α) :=
  fun ((l, r) : α  × β ) => (r, l)

-- It computes!
#eval swap' (true, 3)

-- Think about associativity of pairing via (_, _).
#eval swap' ((1,2),3)
#check swap' ((1,2),3)

#eval swap' (1,(2,3))
#check swap' (1,(2,3))

-- Note that (_,_) is right associative.

/- @@@
### Curry-Howard Correspondence
*Prod* is like *And*. And takes two propositions,
say P and Q, as its argument. Prod, by contrast,
takes two *computational* types, such as String
and Bool. A value of either then is then a pair.
A proof of *And P Q* (P ∧ Q) is a pair of proofs,
one of P and one of Q. A value of *Prod α β* is a
pair of values, the first of type α, the second
of type β. They are Curry-Howard twin types.
@@@ -/

def myAndComm {α β : Prop} : (α ∧ β) → (β ∧ α) :=
  fun (⟨l, r⟩  : α  ∧ β ) => ⟨r, l⟩

/- @@@
## Sum Types Mirror Or

A value of a type, *Sum α β* represents *either*
a value of type α or a value of type β. This is
exactly how *Or* works: a proof of *Or P Q* is built
from *either* a proof of P or a proof of Q. The way
we *use* a value of a Sum type is by case analysis.
It's just like *Or* but now we're computing with
ordinary data rather than with proof values.


```
inductive Sum (α : Type u) (β : Type v) where
  | inl (val : α) : Sum α β
  | inr (val : β) : Sum α β
```
@@@ -/


#check Sum String Bool      -- abstrac syntax
#check String ⊕ Bool

/- @@@
### Sum Introduction
To construct a value of a Sum type, *Sum α β* in Lean,
one uses either *Sum.inl (a : α)* or *Sum.inr (b : β).
Here are some examples.
@@@ -/

def s0 : String ⊕ Bool := Sum.inl "Hi"
def s1 : String ⊕ Bool := Sum.inr true

-- Both values are of the same Sum type
#check s0
#check s1

-- ⊕ (Sum) is right associative
#check String ⊕ (Bool ⊕ Nat)
#check (String ⊕ Bool) ⊕ Nat

def e : String ⊕ Bool := Sum.inl "Hi"
def g : String ⊕ Bool := Sum.inr true

/- @@@
### Sum Elimination

The elimination rule, or *how we use*, a value
of a Sum type is by case analysis. Suppose the
function, *either*, takes either a string or a
Boolean and that it has to return a Nat: let's
say 0 if the argument is a string and 1 if it's
a Boolean. Here you go.
@@@ -/

def either : String ⊕ Bool → Nat :=
  fun sorb =>
    match sorb with
    | Sum.inl _ => 0
    | Sum.inr _ => 1

def either' : String ⊕ Bool → String :=
  fun sorb =>
    match sorb with
    | Sum.inl _ => "string"
    | Sum.inr _ => "bool"

#eval either (Sum.inl "Hi")
#eval either (Sum.inr false)

#eval either' (Sum.inl "Hi")
#eval either' (Sum.inr false)

/- @@@
### Functions Involving Sum

We can of course now define functions involving
objects of Sum types. Here's one that takes as an
argument either String or Bool and returns either
Bool or string. It's just like P ∨ Q → Q ∨ P!
@@@ -/

def sum_comm : (String ⊕ Bool) → (Bool ⊕ String) :=
fun h : String ⊕ Bool =>
  match h with
  | Sum.inl s => Sum.inr s
  | Sum.inr b => Sum.inl b

def sum_assoc {α β γ : Type} : α ⊕ (β ⊕ γ) → (α ⊕ β) ⊕ γ :=
fun h =>
(
  match h with
  | Sum.inl a => Sum.inl (Sum.inl a)
  | Sum.inr bc => match bc with
                  | Sum.inl b => Sum.inl (Sum.inr b)
                  | Sum.inr c => Sum.inr c
)

/- @@@
EXERCISE: Prove it in the other direction.

Having proved it in both directions, you know
only that there are functions of these types
in both directions. But to have an equivalence
in *Type*, it also has to be the case that the
two function are inverses. What that means is
that if you start with any value of the first
type, v1, apply the first function to it to
get w1, then apply the second function to that,
you will always get right back to v1. Formally
a *computational* equivalence is a structure,
@@@ -/

structure equivalence
  { α β : Type }
  (forward : α → β)
  (backward : β → α)
  (left : ∀ (a : α), backward (forward a) = a)
  (right : ∀ (b : β), forward (backward b) = b)

-- In Lean, it's Equiv

#check Equiv

/- @@@
### Curry-Howard Correspondence

Here's a function involving Sum types that perfectly
mirrors our proof that *Or is associative*.
@@@ -/

example {α β γ : Type} : (α ⊕ β) ⊕ γ → α ⊕ (β ⊕ γ) :=
  fun h : (α ⊕ β) ⊕ γ =>
  (
    match h with
    | Sum.inl asumb =>
    (
      match asumb with
      | Sum.inl a => Sum.inl a
      | Sum.inr b => Sum.inr (Sum.inl b)
    )
    | Sum.inr c => Sum.inr (Sum.inr c)
  )

/- @@@
## What About Not?

We'll define it as the computational
analog of our definiton of logical *Not*.
Give a proposition, P, we defined ¬P to
mean just P → False. The computational
analog, for any type, (α : Type), is
the function type, α → Empty. Empty is
a standard uninhabited type defined by
Lean.
@@@ -/

def Ng α := α → Empty

/- @@@
### Ng Shows Uninhabitedness
As an example we define uninhabited
type, *Nuttin*, an analog of *False*,
then, to "prove" that Nuttin is empty,
we show that there is a function of
type *Nuttin → Empty*.
@@@ -/

inductive Nuttin where      -- uninhabited
example : Ng Nuttin := (fun h => nomatch h)

/- @@@
### Examples

If you have a box with both an a and a b,
can you produce a box with either an a or
a b? Yeah. In fact there are two different
ways: produce a box with a an, or produce
a box with a b.
@@@ -/

example {α β : Type} : α × β → α ⊕ β :=
(
  fun (a, _) => Sum.inl a
)

example {α β : Type} : α × β → α ⊕ β :=
(
  fun (_, b) => Sum.inr b
)

/- @@@
A sillier question is, if you have either
and a or a b, can you get from that an a
and a b? In other words, can you define a
function that accepts a (aorb : α ⊕ β) and
given only that data returns an α × β? No,
of course not. One can go a certain way but
not beyond. Uncomment the following example.
Put it back in a comment when done.
@@@ -/

-- Uncomment the following definition to see Lean's error showing the stuck proof state:
/-
example {α β : Type} : α ⊕ β → α × β :=
(
  fun h => match h with
  | Sum.inl a => _
  | Sum.inr b => _
)
@@@ -/

example  : Nat ⊕ Bool → Nat × Bool :=
(
  fun h => match h with
  | Sum.inl a => (a,true)
  | Sum.inr b => (0, b)
)

/- @@@
We're stuck, unable to construct a function
of this type. Indeed, we can produce a counter
example. Let α = β = Empty!
@@@ -/

-- Uncomment the following definition to see Lean's error showing the stuck proof state:
/-
example {α β : Type} : Ng (α ⊕ β → α × β) :=
(
  fun h => _
)
@@@ -/

def eSumImpEProd : (Empty ⊕ Empty) → (Empty × Empty) :=
  fun h => nomatch h

/- @@@
### Example: Lunchtime Logic
@@@ -/

inductive Meat : Type
| chicken
| beef

inductive Cheese : Type
| cheddar
| gruyere

inductive Bread
| wheat
| rye

/-
#### Commutativity of Sum in Context
@@@ -/

example: Bread × (Meat ⊕ Cheese) → Bread × (Cheese ⊕ Meat) :=
(
  fun ⟨ b, mc ⟩ => ⟨b, match mc with
                        | Sum.inl m => Sum.inr m
                        | Sum.inr c => Sum.inl c
                    ⟩
)

/- @@@
#### Distributuion of Prod over Sum
@@@ -/

example : Bread × (Meat ⊕ Cheese) → (Bread × Meat) ⊕ (Bread × Cheese) :=
fun h =>
  let b := h.fst
  let mc := h.snd
  match mc with
  | Sum.inl m => Sum.inl (b, m)
  | Sum.inr c => Sum.inr (b, c)

/- @@@
#### DeMorgan-like: Negation over Prod
@@@ -/

open Bread
open Cheese

example : Ng (Bread × Cheese) → Ng Bread ⊕ Ng Cheese :=
fun h =>
(
  nomatch (h (rye, cheddar))
)

/- @@@
## Summary: The Curry-Howard Correspondence

The Curry-Howard correspondence shows a deep connection between
logic and computation. Types in programming correspond to propositions
in logic, and programs correspond to proofs.

### Type-Proposition Correspondence

| Computation (Type) | Logic (Prop) |
|--------------------|--------------|
| `Prod α β` (α × β) | `And P Q` (P ∧ Q) |
| `Sum α β` (α ⊕ β) | `Or P Q` (P ∨ Q) |
| `α → β` | `P → Q` |
| `Unit` | `True` |
| `Empty` | `False` |

### Operation Correspondence

| Computation | Logic |
|-------------|-------|
| `Prod.mk a b` / `(a, b)` | `And.intro p q` / `⟨p, q⟩` |
| `fst`, `snd` | `And.left`, `And.right` |
| `Sum.inl a` | `Or.inl p` |
| `Sum.inr b` | `Or.inr q` |
| `match` on Sum | `Or.elim` / case analysis |
| Function application | Modus ponens |
| `nomatch` on Empty | `False.elim` |

### Key Insight

A proof of P → Q is a function that transforms proofs of P into proofs of Q.
A proof of P ∧ Q is a pair of proofs.
A proof of P ∨ Q is either a proof of P or a proof of Q (tagged).

This correspondence means:
- Type checking = Proof checking
- Programming = Proving
- Running a program = Simplifying a proof
@@@ -/

end Content.book1lib.chapters.C10_curryHoward
