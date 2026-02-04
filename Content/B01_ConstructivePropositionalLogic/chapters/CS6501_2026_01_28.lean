namespace CS6501S26

/- @@@
# Propositions as Types with Proofs as Values

You're already deeply familiar with Boolean algebra and
thus with the central concepts in propositional logic. The
only differences in practice is that we use logical rather
rather than Boolean notations, e.g., ∧ instead of &&, when
writing propositions.

The purpose of this class is to reinforce the notion that we
can give a very different presentation of propositional logic,
where we represent propositions as *types*, and proofs of them
as *values* of such types. But before we get there, let's very
quickly review propositional logic.

## Review of Classical Truth-Theoretic Propositional Logic

Propositional logic comprises the following fundametal ideas.
There are propositions. A proposition can be judged *true* or
*false*.  Smaller propositions can be combined into larger ones
using logical connectives. When a larger proposition is built
from smaller ones, e.g., *SkyBlue ∧ EarthGreen*, its truth is
determined by ascertaining the truth of its sub-propositions
and by then applying the truth function for the given connective
(here *and*) to those (here two) values. For *and*, this *truth
function* returns true if both arguments are true, and otherwise
it returns false.

## This Class: Constructive Propositional Logic

The purpose of this class is to reinforce the notion that we
can use *types* to represent logical propositions, and values
of such types to represent proofs of them. A type representing
a proposition that has at least one value, i.e., that has some
proof, is judged valid/true. A type representing a proposition
that has no values will be judged a false proposition. Finally,
to judge a larger proposition to be true, we must have a proof
ot it, which will typically require proofs of at least some of
its parts, often along with other values. We are thus now on a
path to simulating *contructive, proof-theoretic* propositional
logic, rather than the truth-theoretic logic of Boolean algebra.
Logic is now programming, where programs construct proof values.

## Elementary Proposition, Proof, and Conjunction Types

We'll work out one complete example where we are given two
propositions, each with a proof (thus valid/true), where we
then form and prove the two conjunctions (propositions), in
each order. We show that from a proof of either conjunction
we can always extract proofs of the individual conjunctions.
Finally we show that from a proof of the conjunction in one
order we can always derive a proof of the conjunction in the
other order. As a programming matter, it's swapping the order
of the proofs in the given proof. Finally, we introduce the
notion of a logical equivalence, which occurs when a proof
of one proposition can be turned into a proof of the other
in both directions. Here are the concepts we'll *simulate*
using simple special cases of ordinary data types and values.

- The sky is blue. A type (SkyBlue : Type)
- There is a proof of it: (SkyBlue.intro : SkyBlue)
- The earth is green. A type, (EarthGreen : Type)
- THere is a proof of it: (EarthGreen.intro : EarthGreen)
- The sky is blue and the earth is green. A type:
  - SkyBlueAndEarthGreen
  - SkyBlue × EarthGreen (Prod SkyBlue EarthGreen)
- The earth is green and the sky is blue.
  - EarthGreenAndSkyBlue
  - EarthGreen × SkyBlue
- Proofs of conjunctions join two proofs together into one, a pair
-- From proof, one can derive constituent proofs of the respective conjuncts
  - If the earth is green and the sky is blue, then the sky is blue.
    - A Proposition. A type. A function type.
      - EarthGreen × SkyBlue → SkyBlue. An implication. A proposition. A type.
      - A proof is a function that turns a given pair into its right element
      - Given such a function f and (pf : EarthGreen × SkyBlue) then (f pf) proves SkyBlue
  - If the earth is green and the sky is blue, then the earth is green. Same thing.
- If the sky is blue and the earth is green, the the sky is blue. Same thing.
- And (here written as ×) is commutative.
  - Any proof of P × Q can be turned into a proof of Q ∧ P
  - And proof of Q × P can be turned into a proof of P ∧ Q
  - Given that each can be converted to the other, they're equivalent: P ∧ Q ↔ Q ∧ P
    - If the earth is green and the sky is blue, then the sky is blue and the earth is green.
    - If the sky is blue and the earth is green then the earth is green and the sky is blue.
- The equivalence : not fully proved but you can see it: it's just pair-swap in each direction

## Elementary Types and Proofs
@@@ -/



-- The sky is blue. A type (SkyBlue : Type)
inductive SkyBlue : Type where
-- There is a proof of it: (SkyBlue.intro : SkyBlue)
| intro

-- The earth is green. A type, (EarthGreen : Type)
inductive EarthGreen : Type where
-- There is a proof of it: (EarthGreen.intro : EarthGreen)
| intro


-- Declare and define (name) proofs of each
def valSkyBlue : SkyBlue := SkyBlue.intro           -- just a simple value of a simple type
def pfSkyBlue : SkyBlue := SkyBlue.intro            -- now suggested to view it as a proof
def pfEarthGreen : EarthGreen := EarthGreen.intro   -- also view value as proof of EarthGreen
-- Note: any value will do to "prove" a proposition


/- @@@
### A Connective: Conjunction (And, ∧)

In the context of this Lean file, we now have proofs
of SkyBlue and of EarthGreen. Suppose we want both to
express and then to prove the proposition, in logical
notation, that SkyBlue ∧ EarthGreen. For this we need
a new type, and we want it to have a proof when there
are proofs of both SKyBlue and EarthGreen. We'll call
the new type, SkyBlueAndEarthGreen. The crucial trick
is to define just a single value/proof constructor, we
call it intro, that requires proofs of each conjunct in
the right order to fully construct a proof value of this
hand-crafted, domain-specific *conjunctive* type. We'll
enclose this first version of our designs in a namespace
to avoid later name conflicts.
@@@ -/

namespace version1

-- "The sky is blue AND the earth is green" as a type
inductive SkyBlueAndEarthGreen : Type where
-- A proof can only be constructed from proofs of its conjuncts
| intro : SkyBlue → EarthGreen → SkyBlueAndEarthGreen

-- "Thethe earth is green AND sky is blue" as a type
inductive EarthGreenAndSkyBlue where
-- The constructor requires the same arguments in the other order
| intro : EarthGreen → SkyBlue → EarthGreenAndSkyBlue
-- proofs of conjunctions are ordered pairs

-- Proofs of conjuctions available so we can prove conjunction
def pfSkyBlueAndEarthGreen := SkyBlueAndEarthGreen.intro SkyBlue.intro EarthGreen.intro
def pfEarthGreenAndSkyBlue := EarthGreenAndSkyBlue.intro EarthGreen.intro SkyBlue.intro

/- @@@
Given the meaning we've now conferred on *And* we can
intuit that if some proposition, *P ∧ Q* is true, then
*P* itself must be true (as a proof of it was required
to have a proof of P ∧ Q). The same goes for Q. In plain
English, if we have a proof of P ∧ Q then we can use it
to derive a proof of P. The same goes for Q. So if P ∧ Q
is true (with a proof) the there is a proof that witnesses
the truth of P, and the same goes for Q. You just extract
the respective proof from the given pair of proofs. In
logical language, we'd say P ∧ Q → P and P ∧ Q → Q.

Of course these are also propositions: implications. They
do not say there is a proof of P or of Q, they say only that
if there is a proof of P ∧ Q then there is a proof of P, and
of for Q as well. These propositions are represented as types
by the use of *function* types. A proof of the proposition
*P ∧ Q → P* is simply a function value of this *function
type*, a kind of function that *if given* a value/proof of
type P ∧ Q, will reduce to and return a proof of P.

Here, P = SkyBlue, Q = EarthGreen. We'll call our claims
(propositions) that our propositions are true by defining
proof conversion functions with names that suggest their
logical meanings: e.g., EarthGreenAndSkyBlue2SkyBlue.
@@@ -/

def EarthGreenAndSkyBlue2SkyBlue : EarthGreenAndSkyBlue → SkyBlue
| ⟨ pfeg, pfsb ⟩ => pfsb

def EarthGreenAndSkyBlue2EarthGreen : EarthGreenAndSkyBlue → EarthGreen
| ⟨ pfeg, pfsb ⟩ => pfeg

/- @@@
With just that much we can now assert even more interesting
propositions, such as the claim that "and is commutative".
That means that a conjunction, P ∧ Q, is true, as witnessed
by a proof, if and only of Q ∧ P does. In logical terms we
would say P ∧ Q ↔ Q ∧ P. It should be clear to a programmers
that as a proof of P ∧ Q is just ⟨ p, q ⟩ and what's needed
to prove Q ∧ P is ⟨ q, p ⟩ we can apply our projection (field
access) functions to get p and q from the supposed proof of
P ∧ Q and then put them back together using the conjunctive
*intro* rule into proof of Q ∧ P. Here we'll give a proof in
one direction only.
@@@ -/

def forward : EarthGreenAndSkyBlue → SkyBlueAndEarthGreen
| EarthGreenAndSkyBlue.intro eg sb  =>  -- Abstract syntax
  ⟨ sb, eg ⟩                            -- Notation easier

def reverse :  SkyBlueAndEarthGreen → EarthGreenAndSkyBlue
| pf => ⟨ pf.2, pf.1 ⟩  -- numeric field access (one constructor)

-- What we have then is an equivalence. A proof of either
-- will do as now you can always convert one to the other.
end version1


/- @@@
In this version we abandon our custom conjection types in
favor of specializations of the polymorpic Prod (product,
ordered pair) type. Instead of our EarthGreenAndSkyBlue type,
for example, we'll use (Prod EarthGreen SkyBlue), the type of
ordered pairs of values/proofs of the two types/propositions.

Here abbrev binds our old type names to specializations of
Lean's standard (polymorphic) product type, Prod. One can
use either the name on the left or the product type expression
on the right interchangeably thenceforth.
@@@ -/

namespace version2

abbrev SkyBlueAndEarthGreen := SkyBlue × EarthGreen
abbrev EarthGreenAndSkyBlue := EarthGreen × SkyBlue

-- Proofs
def pfSkyBlueAndEarthGreen : SkyBlue × EarthGreen := ⟨ SkyBlue.intro, EarthGreen.intro ⟩
def pfEarthGreenAndSkyBlue : EarthGreen × SkyBlue := ( EarthGreen.intro, SkyBlue.intro )

-- Eliminations
def leftEarthGreenAndSkyBlue : EarthGreen × SkyBlue → EarthGreen
| pr  => pr.1
def rightEarthGreenAndSkyBlue : EarthGreenAndSkyBlue → SkyBlue
| pr  => pr.2
def leftSkyBlueAndEarthGreen : SkyBlueAndEarthGreen → SkyBlue
| pr  => pr.1
def rightSkyBlueAndEarthGreen : SkyBlueAndEarthGreen → EarthGreen
| pr  => pr.2


-- Commutativity: Proofs of *implications* in both directions, each proof thus being a function
def SkyBlueAndEarthGreenImpEarthGreenAndSkyBlue : SkyBlue × EarthGreen → EarthGreen × SkyBlue
| ⟨ sb, eg ⟩ => ⟨ eg, sb ⟩
def EarthGreenAndSkyBlueImpSkyBlueAndEarthGreen : SkyBlue× EarthGreen → EarthGreen × SkyBlue
| ⟨ eg, sb ⟩ => ⟨ sb, eg ⟩

end version2


/- @@@
## Review of Sum and Prod

```
inductive Sum (α : Type u) (β : Type v) where
  | inl (val : α) : Sum α β
  | inr (val : β) : Sum α β
```

```
structure Prod (α : Type u) (β : Type v) where
  mk :: (fst : α) (snd : β)
```
@@@ -/

#check Sum
#check Prod



/- @@@
## Logical P ∨ Q as Sum, P ⊕ Q
@@@ -/


-- Proofs of both disjunctions
def EarthGreenOrSkyBlue1 :  EarthGreen ⊕ SkyBlue := Sum.inl pfEarthGreen
def EarthGreenOrSkyBlue2 :  EarthGreen ⊕ SkyBlue := Sum.inr pfSkyBlue

-- Commutativity
def forward : EarthGreen ⊕ SkyBlue → SkyBlue ⊕ EarthGreen
| Sum.inl eg => Sum.inr eg
| Sum.inr sb => Sum.inl sb


/- @@@
## What About Not

If we represent a proposition, let's say
fire is cold as a type and we mean for that
proposition to be judged false, then we just
have to define the type to have no values,
or equivalently the proposition has no proofs.

A type with no values is said to be empty or
uninhabited. You can define your own empty
inductive type anytime you want. (Don't use
structure, or you'll end up with *mk* as a
default constructor, a value of that type.)
@@@ -/

inductive WaterDry where

/- @@@
That's it. No constructors. No proof. Viewed
as a proposition, knowing for sure that it has
no proofs, we can judge it to be logically false.
We will soon introduct the connective, *Not*, that
applies to one proposition, yielding a *negation*
as a proposition and that we should judge to be
true exactly when the proposition it's applied to
is false. We can thus judge WaterDry to be false.
@@@ -/

/- @@@
## The Truth Table for Implies
Before we introduce the concept of negation in
detail, let's do a sanity check. We already have
the truth table for implies propositional logic.
We now have a false proposition and several true
ones. One true one is EarthGreen, witnessed by
the proof term/object/value, EarthGreen.intro.

The classical rules for implies are these:

- false → false is true
- false → true is true
- true → false is false
- true → true is true

What about corresponding propositions in our
world of proof-theoertical propositional logic?
style of reasoning?

- WaterDry → Empty
- WaterDry → EarthGreen
- EarthGreen → WaterDry
- EarthGreen → SkyBlue
@@@ -/

def f2f : WaterDry → Empty
| wd => nomatch wd

def f2 :  WaterDry → EarthGreen
| wd => EarthGreen.intro

-- def f3 : EarthGreen → WaterDry
-- | eg => _

def f4 : EarthGreen → SkyBlue
| _ => SkyBlue.intro


example : WaterDry → Empty := sorry
example : WaterDry → EarthGreen := sorry
example : EarthGreen → WaterDry := sorry
example : EarthGreen → SkyBlue := sorry

/- @@@
# What About Not?

Ready?
@@@ -/

def Nott := (α : Type) → Empty


end CS6501S26
