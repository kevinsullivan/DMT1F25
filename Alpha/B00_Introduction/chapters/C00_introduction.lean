structure Foo where
(t : Type 0)
(n : t)


#check Foo.mk Bool true
#check Foo
/- @@@
# Logics

Follow along at https://live.lean-lang.org/

Logics are languages for expressing mathematically
precise and unambiguous *claims* about *worlds* (to
which such claims are applicable), and for reasoning
about (1) the truth of such propositions applied to
any particular worlds, or (2) their truth in *all*
possible worlds.

In the case of a proposition that is true of *all*
worlds to which it's applicable, we can say that the
the proposition is *valid*. In mathematics and logic,
we will often call a valid proposition a *theorem*.

## Examples

### Booleans

You know from Boolean algebra that if you take the
*and* (conjunction, &&) of Boolean false with any
other Boolean value, b, that the result is always
false. This is by the definition of Boolean *and*.
We can express this •generalization* in predicate
logic, as *∀ (b : Bool), (false && b) = false*.
@@@ -/

def boolClaim : Prop :=
  ∀ (b : Bool), (false && b) = false

/- @@@
Our *goal* now is to construct a proof of it.
We always start by simple syntax-based analysis
of the proposition we seek to prove. Here we see
that the proposition has as its central logical
operator, the ∀ quantifier. This is a *for all*
proposition, also known as a generalization. We
are thus forced to use one of the *axioms* of
logical reasoning that works for this type of
claim.

In Lean, where proofs are literally written as
programs (including simple data structures), that
means we need to write a kind of program that
proves a generalization.

A big hint comes from the English reading of the
proposition: "If you pick *any* Boolean value, *b,*
the value of the expression, *false && b* is false.
It's a classic *universal generalization*, stating
that *false && b = false* *for all/any Boolean, *b*.

To reason about whether the whole proposition is
true, will *assume* you're given *any* (b : Bool).
in the context of that *binding* (of *b* to *some*
specific but unspecified Boolean value), we must
then show that *false && b* is *false*. If it's true
in every possible individual case, then it's true for
all *b*.

Here there are just two cases: *b* can be *true*;
*b* can be *false*. That is *all* of the values *b*
can take on. What if *b* is false? Then *false &&
b = false* as *false && false* is false *by the
definition* of the Boolean *and* operator (&&).
What if *b* is true? Again, because *false && true*
reduces to *false*, we have *false = false*, which,
finally, is true, by the definition of equality.

Once we've assumed that we have some arbitrary *b*,
we can finish the proof by considering each possible
case for the value of *b* separately. We call this a
*proof by case analysis*.

Here's the actual definition of the Bool type in
Lean's core library. The key fact to understand is
that such a definition is exhaustive. It defines
only, and *all*, values of the specified type. There
are no additional values (error values for example).
So showing a proposition is true for all values in
this case really does reduce to showing that it's
true in each of the two cases, as that's all of'em.

```
inductive Bool : Type where
  /-- The Boolean value `false`, not to be confused with the proposition `False`. -/
  | false : Bool
  /-- The Boolean value `true`, not to be confused with the proposition `True`. -/
  | true : Bool
``


So now let's look at a *formal, machine checkable*
version of our proof by intuitive reasoning, written
in English (or any natural language)
@@@ -/

example : ∀ (b : Bool), (false && b) = false :=
  -- We'll "assume" *b* is a Boolean by defining a function taking *b* as a parameter
  fun b =>
    match b with
    | true => rfl
    | false => rfl


/- @@@
Here, *example* is a keyword that let's you state a
type of object that you want to provide and have Lean
check for type/logical correctness. The proposition
follows after the syntactic *:* separator. Then another
separator, *:=*,  introduces thae actual proof object.
These objects are just data of particular types, in some
cases data types, in some cases function types, etc.


data or function types. in the
form of a *program* (data structure, function, etc). In
constructive logic proofs are programs of the types that
encode the propositions that they prove. This is a deep
and important and now industrially relevant idea in the
Logic, Formalized Mathematics, Computer Science, and
other fields.

Here the proof is a function taking one parameter, *b*,
analyzing it (case analysis, by matching b with each of
its possible forms), and providing a proof of each and
every (here just two) special cases.

In English: Let b e an arbitrary Bool. We wish to show
that b && false is false in all cases. There are only
two cases to consider: *b = true*, and *b = false*. We
consider each case in turn. In the case where *b = true*
we must show that true && false = false. This is a true
equality proposition because by the definition of *&&*,
*true && false* reduces to *false.* The same reasoning
applies to the second case, to show that in all cases,
b && false is false.

Now English (or natural language more generally) is nice
for human communication, but it has its weaknesses. It's
for this reason mathematicians and logicians invented the
use of *formal languages* to express mathematical claims,
and, indeed proofs. Here then is the statement of our
little *theorem*. We've proven it true in all worlds,
where a world, in this case, is just a binding of *b*
to one of its two possible values.
@@@ -/


/- @@@
### Social World

Consider an example. Start by imagining a world in
which there are people, and facts concerning who in
the world likes who else in the world. For example,
suppose our world has two people: Irma and Rufus,
and that

- Irma Likes Irm
- Irmal Likes Rufus
- Rufus Likes Irma
@@@ -/

-- Data type with two values
inductive Person : Type where
| Irma : Person
| Rufus : Person

open Person

-- Binary Person-to-Person *Likes* relation
-- With three "values" (proofs) of this "type" (proposition)

inductive Likes : Person → Person → Prop where
| ii : Likes Irma Irma
| rr : Likes Irma Rufus
| ri : Likes Rufus Irma

/- @@@
### Claim

With our little world defined, we can now assert claims
about it. For example, we might claim that, in our world,
*everyone likes everyone*.

Here we defined *claim* to be the name of a proposition
(of type *Prop*), namely the proposition that asserts that
if p1 and p2 refer to any two people, then it is the case
that those two people like each other, whic is to say that
p1 Likes p2.
@@@-/

def claim : Prop := ∀ (p1 p2 : Person), Likes p1 p2

/- @@@
### Verification

Not every claim someone makes is necessarily true. In
general, one must verify claims. Deducative reasoning
is a method of verifying claims expressing in logics
include propositional and predicate logic.

Here we want to check whether *claim* is true in our
world defined by *Person* and *Likes*. Knowing that
*p1* can refer to any Person, and that there are only
two Persons, we'll just check each case.

First, suppose *p1 = Irma*. Within this case, first
suppose *p2 = Irma*. We have our first of four cases:
the proposition that *Irma Likes Irma*. And we have a
proof of it. We also have proofs of *Irma Likes Rusus*
and *Rufus Likes Irma*.

What we don't have is a proof of *Rufus Likes Rusus.*
We are thus unable to construct a proof that everyone
likes everyone by showing that it's true in of of the
possible special cases (here four).

To avoid proof failures in our file here, we comment
out the almost complete but but ultimately impossible
proof construction. Uncomment it to see that Lean tells
us exactly what's wrong:
@@@ -/


/--
error: unsolved goals
case Rufus.Rufus
⊢ Likes Rufus Rufus
-/
#guard_msgs in
example : ∀ (p1 p2 : Person), Likes p1 p2 :=
  fun p1 p2 =>
  by
    rcases p1
    rcases p2
    constructor
    constructor
    rcases p2
    constructor
    -- stuck: no path to finish proof



/- @@@
### Negation

You might expect that being able to see intuitively
that there's no way to complete a proof would show that
the proposition is false. THAT is not a valid form of
reasoning in the constructive logic of Lean. If we want
to show that it's false that everyone likes everyone, we
need an actual proof of it. First, here's the claim
stated formally.
@@@ -/

def notEveryoneLikesEveryone : Prop := ¬claim

/- @@@

The ¬ symbol is read as *not*. So *¬claim* means exactly
*¬(∀ p1 p2, Likes p1 p2)*. The way we'll prove that *¬claim*
is true is by proving that *claim* is false. The way we'll
show that *claim* is false is by showing that if it were to
be true, then an impossible condition would hold. As that is
in fact not possible, *claim* simply *cannot* be true. That
is a stronger statement than "we see that we can't finish a
proof*. So as *claim* demonstrably can't be true it must be
false. And so the claim, or proposition, *¬claim*, is true.

To put this succinctly, if you show that the hypothesis that
claim is true leads to a contradiction, then you have shown
that that hypothesis cannot be true and so must be false.

To generalize, if *P* is any proposition, then to prove *P*,
assume it's true, as witnessed by a proof of it, and show that
from that assumed proof something impossible can be derived.
From that, you may deduce that ¬claim is true. This reasoning
pattern is called *proof by negation* and it's how we prove
propositions in the form of *negations* in particular *(¬P).*

So where does a contradiction come from in this case? Well,
...
@@@ -/

example : ¬claim := by
  -- introduce as a hypothesis h that claim is true
  intro h
  -- expand the definition of claim
  unfold claim at h
  -- specialize h by application to Rufus twite
  have contra := h Rufus Rufus
  -- such a proof can't exist; it'd contradict the definition of Likes
  -- this hypothesized proof doesn't match any of the available proofs
  nomatch contra
  -- inductive types definitions are exhaustive; no other values exist.
  -- this fourth case can't actually occur and so can be ignored.


/- @@@
## Example: BulbWorld

So far when we've said "worlds" we've meant related
worlds. In our preceding example, worlds were related
and could vary in (1) the numbers and names of people,
and (2) the definition of the Likes relation on the
given set of people. This exanple has two worlds. In
one, *on*, a light bulb is on; and in the other, *off*,
it's off.

### World Types and Instances

In our formal (mathematical) model of this scenario,
we define *BulbWorld* as the *type* of worlds under
consideration, and *on* and *off* as the two worlds
of this type.
@@@ -/

inductive BulbWorld where
| on : BulbWorld
| off : BulbWorld
open BulbWorld

/- @@@
### A Few Lean Details
@@@ -/

-- #check typechecks and reports the type of the given term
#check BulbWorld.on
#check BulbWorld.off

-- as we opened the BulbWorld namespace, we can skip the qualifier
#check on
#check off


/- @@@
### *My* World
Suppose *my* world is one in which the bulb is on. We
will express this idea formally by binding the variable
name, *myWorld*, to *BulbWorld.on*. My own home world is
*on*.
@@@ -/

def myWorld := on

#check myWorld

-- #eval evaluates expressions and return their meanings
#eval myWorld

/- @@@
#### A False Claim
Now we get to logic, where we can express precise
unambiguous claims about given worlds. We will call
such claims *propositions*. For examnple, the claim
that *myWorld is the off world* is a proposition. To
be mathematically precise, we write *myWorld = off*.
@@@ -/

def falseClaim := myWorld = off

/- @@@
#### Equality Relations

This Proposition assumes that there's a binary
equality relation on objects of comparable types.
Just as we defined *Likes* as a binary predicate,
taking two person arguments, *Eq* takes two terms
(expressions), say *x* and *y*, of any common type,
to form the proposition that we write as *x = y*.
The real trick is in defining what counts as proof
of such a proposition.

Two Lean terms (expressions) of the same type have
a proof of equality if the two *expressions* reduce
(evaluate) to the same value. We say such terms are
*definitionally equal* in Lean.

Consider the proposition, 1 + 1 = 2. The *expressions*
themselves on the left and right side of the = sign
are evidently *not* equal. But the values that each
of these expressions represents, and *computes*, are
equal, so we want to judge this equality proposition
to be true. And that's how Lean thinks about it, too.
@@@ -/

#check 1 + 1 = 2
#check (Eq.refl 2 : 1 + 1 = 2)

/-
The one remaing trick is to define *all* the proofs
of *all* true equality propositions with one rule.
In Lean, it's called *Eq.refl*. You just saw it used,
where we used #check to check the type of *Eq.refl 2*.
This is a term (value) of *type* *2 = 2*, and *2 = 2*
is a proposition, making *Eq.refl 2* a proof of it.
And moreover, this term is also accepted as a proof of
*1 + 1 = 2*, because *1 + 1* is *definitionally equal*
to *2*, and reduces to *2* making both sides equal,
with *Eq.refl 2* being a proof of the reduced equality
proposition.

More generally, *Eq.refl* implements the *introduction*
inference rule for equality. Using it introduces a new
proof: of an equality proposition. To be completely
precise about it, if α is any type and *a : α* is any
value of type α, then the term *Eq.refl a* is accepted
as a proof of the proposition, *Eq a a*, for which Lean
provides the usual notation, *a = a*. In short, *Eq.refl*
takes a type and one value of that type and hands you a
proof that that object is equal to itself.
@@@ -/


-- Takes any type α and two α values and yields a proposition
#check @Eq

-- Takes two Nat values and yields a proposition
#check @Eq Nat

-- The proposition, 0 = 1
#check @Eq Nat 0 1

-- The same proposition where Lean infers Nat from the next argument (0)
-- The purpose of the @ is to turn off argument inference when enabled
#check Eq 0 1

-- There's not context to infer String so it must be explicit in this case
#check @Eq String

--
#check (Eq.refl "Hello")
#check (Eq.refl 5)

-- If Lean can infer both α and *a* you can use shortcut *rfl*
#check (rfl : 3 = 3)
#check (rfl : true = true)
#check (rfl : "Hi!" = "Hi!")

example : 3 = 3 := rfl
example : true = true := rfl
example : "Hi!" = "Hi!" := rfl

/- @@@
## Equality is a Relation

We'll introduce the notation *Eq x y* for a binary
relation on pairs of objects of the same type. And
finally we'll see Lean

What pairs of objects are in equality relations in
Lean?

What type of thing is *myWorldIsOff?* It's A
propposition (Prop). What particular proposition
is it? *myWorld = off!* But as a proposition is
it true?

Here comes the fun part: reasoning. Is this proposition
true? Intuitively we can see it's clearly not true. It's a
perfectly good proposition, but, we intuit, it's not true.

But intuition isn't precise mathematical reasoning. What
kind of precise reasoning is needed to deduce that this
particular proposition is not true?

Well, the kind of reasoning needed is first determined
by the type of the proposition that's being considered.
So what type of proposition is *myWorldIsOff?* It's an
*equality* proposition. It asserts that two things are
equal (even though here's they're not).

What we need to understand, then, is how to reason about
the truth of equality propositions. Here's the rule. You
can have a proof that any object is equal to itself and
you can never have a proof that any object is equal to any
other object.

A function that produces proofs of equality propositions
thus needs only take *one* object, call it *o*, as input,
returning a proof of the proposition, *o = o*. Here we'll
use *Eq.refl* as the name of this machine.
@@@ -/

-- A proof of *myWorld = myWorld*
#check Eq.refl myWorld

-- A proof of *on = on*
#check Eq.refl on

-- A proof of *off = off*
#check Eq.refl off

-- A proof of *3 = 3*
#check Eq.refl 3

-- A proof of *Cool! = Cool!*
#check Eq.refl "Cool!"


/- @@@
So now to show that an equality proposition, say
*x = y*, is true, you can use either *Eq.refl x*
to get a proof that *x = x*, which will work if
*y* really is the same as *x*; or you can use
*Eq.refl y*, giving you a proof of *y = y*, which
will work as long as *x* is really the same as
*y*. But if *x* and *y* are not the same object,
neither proof will work and you will not be able
to prove that they are equal.
@@@ -/

example : myWorld = myWorld := Eq.refl myWorld

/- @@@
In the particular automated logic we're using here,
*rfl* for *Eq.refl _* that often works. We'll see
more details later.
@@@ -/

def eq1 : myWorld = myWorld := rfl

-- eq1 is a proof of myWorld = myWorld
#check eq1

-- we can check proofs without giving them names
example : 3 = 3 := rfl
example : "Hi" = "Hi" := rfl

/- @@@
And so now the question: Is *myWorld = off* true? It's
not. Why not? Because there's no possible proof of it.
Uncomment the following examples to see that they "do
not compute."
@@@ -/

-- example : myWorld = off := Eq.refl myWorld
-- example : myWorld = off := Eq.refl off
-- example : myWorld = off := rfl

/-@@@
are only two Boolean values (*true* and *false*) in the
logic we're defining here, there are only two possoible
worlds: one where

 let's call it *state*.
So if we have such a world, let's call it *world*, and by
the term, *world.state* we will mean the Boolean state (or
value)

short for the *state* of the world. Given such a world

about is a kind of abstract mathematical world that
has just a single Boolean value in it. That Boolean value
can be either the value *true* or the value *false*


The purpose of a logic is to help one to reason in
valid ways about whether certain claims expressed in
such a language are truenable one to represent
certain kinds of *worlds* with unambiguous mathematical
precision and then to reason deductively about whether
any particular claims about any such world, expressed
in the language of propositional logic, is true or not
in that world.


, in the language of proposition
 what kinds
what kinds of world you can represent using it, how you can
articulate propositions (claims) about such worlds, and how
you can then reason deductively about properties of such worlds.

  how you or a
computer can use it to reason deductively about things
 introduces you to
a revolutionary way of thinking about logic and proof: the idea
that propositions are types and proofs are programs.


@@@ -/
