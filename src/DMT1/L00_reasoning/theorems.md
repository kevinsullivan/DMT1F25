# Theorems

We now have the inference rules, as axioms, that define
exactly how proofs of conjunctions (P ∧ Q propositions)
behave: how you can produce them, and how you can use ones
you have in constructing other proofs).

As a great example, in our logic *we want to know* that
no matter what propositions one start with, our friends
*P* and *Q*, that *P ∧ Q* will be true if and only if (in
other words exactly when) *Q ∧ P* is true. This property
would rule out that *And* imposes any sense of ordering
on its two arguments and would allow one to swap the two
sides of a conjunction at any time with no fear that that
would change its logical meaning.

A problem we face is that we have no *proof* that *And*
always behave this way. So far all we have to work with
are the inference rules: the axioms of *And*. And these
rules alone don't say directly that *changing argument
order never changes meanings*.

In this chapter we will give a crisp exanmple of deductive
reasoning by starting with the axioms of *And* and showing
that *the of commutativity And is a necessary consequence
of taking these particular inference rules as axioms.* To
show that *this* claim (proposition) us true, we will of
course construct a proof of it. Which. Lean. Will. Check!

## Conjectures

In mathematical discourse the word, *conjecture*, refers
to a proposition that one has hypothesized as being true
(often the result of abductive brilliance), for which one
now seeks a proof. Here we have conjectured that *And* is
commutative: for any propositions whatsoever, call them *P*
and *Q* for now, if *P ∧ Q* is true then so must be *Q ∧ P*,
if *Q ∧ P* is true then so must be *P ∧ Q*. So here it is
in the language of predicate logic: our proposition, given
the name, *andCommutes*.


```lean
def andCommutes : Prop :=
  ∀ (P Q : Prop),       -- for *all* propositions, P, Q
    (P ∧ Q → Q ∧ P) ∧   -- if P∧Q is true then Q∧P is true
    (P ∧ Q → Q ∧ P)    -- if Q∧P is true then P∧Q is true
```

At this point we have a formal definition in Lean of the
mathematical claim that *And is commutative*. We don't yet
have a proof of it. To get there we first have to see the
inference rules in enough detail that it's entirely clear
to how how they work to capture the meaning of *And* that
*we* want *for this class*. So let's go.


### Conjunction (And, ∧) is Commutative

When we say that a binary operation, such as ∧, commutes,
or is commutative, we mean that changing the order of the
operands never changes the meaning of an expression. Here,
we nean that for any proposition, P, Q, if you have a proof
that shows P ∧ Q is true you can always convert it into one
showing Q ∧ P is true. In short P ∧ Q → Q ∧ P (and it works
in the other direction, too.)

```lean
theorem proofAndCommutes : andCommutes :=
  fun (_ _ : Prop) =>               -- assume propositions, P, Q
    And.intro                       -- construct proof of conj
      (fun h =>                     -- assume proof P ∧ Q
        (
          And.intro h.right h.left  -- get proof of of Q ∧ P
        )
      )
      (
        sorry
      )


    -- (h : P ∧ Q → Q ∧ P) ∧ (P ∧ Q → Q ∧ P)    =>    -- given a proof of P and Q
    -- fun (P Q : Prop) =>
    --   And.intro           -- construct a proof from
    --   (And.right h)     -- (q : Q)
    --   (And.left h)      -- (p: P), in that order, voila!

-- Here it is using shorthand notation
theorem proofAndCommutes' : P ∧ Q → Q ∧ P :=
  fun (h : P ∧ Q) =>    -- assume we're given proof h
    ⟨ h.right, h.left ⟩ -- construct/return the result
```

There's another whole language in Lean for
writing exactly the same kind of content, but
using higher levels of abstraction provided by
the kind people who have programmed the *tactics*
to automate many parts of proof construction.
For now we'll continue to use bare programming
construct proofs, but be aware of the so-called
*tactic language* as an alternative that you will
eventually want to use.

```lean
theorem proofAndCommutes'' : P ∧ Q → Q ∧ P :=
by                      -- toggles to tactic mode
  intro h               -- introduce h as argument
  let p := And.left h   -- from h extract (p : P)
  let q := And.right h  -- from h extract (q : Q)
  exact  ⟨ q, p ⟩       -- return ⟨ q, p ⟩ : Q ∧ P
```

What we just proved beyond any doubt is that
if P ∧ Q is true (because there's a proof of it)
then invariables Q ∧ P must also be true, because
from that proof of P ∧ Q one can construct a proof
of Q ∧ P.

### Conjection is Associative

One might similarly expect, based on intuition,
that if P, Q, and R are any propositions, then if
(P ∧ Q) ∧ R is true then so is P ∧ (Q ∧ R), and
vice verse. But is that actually true. Here we
show that it's true in the forward direction, as
stated. Your assignment is to show that it's true
in the reverse direction.

```lean
theorem proofAndAssoc : P ∧ Q ∧ R ↔ (P ∧ Q) ∧ R :=
  -- to prove ↔, prove both directions
  Iff.intro
  -- prove forward direction: P ∧ Q ∧ R → (P ∧ Q) ∧ R
  (
    fun
    (h : P ∧ Q ∧ R) =>
    by (
      let p := h.left           -- get smaller proofs
      let q := h.right.left
      let r := h.right.right
      let pq := And.intro p q   -- assumble and retirn
      exact (And.intro pq r)    -- the final proof object
    )
  )
  -- provde reverse: (P ∧ Q) ∧ R → P ∧ Q ∧ R
  (
    fun
    (h : (P ∧ Q) ∧ R) =>
    (
      sorry
    )
  )
```


## Wrap Up: New Ideas

### Implies (→)

You can read the proposition, P → Q, as asserting that
*if P is true then so is Q.* What proves this kind of
proposition, and *implication*, to be true. Here's the
idea. Assume P is true, with a proof p. Now show that
from that p you can construct a proof of Q. That shows
that if P (as witnessed by a proof $p$) then Q is true,
too, as it's always possible to derive a proof of Q from
p.

So that's how you construct a proof of P → Q: provide a
*function* that converts any proof of P into a proof of Q!
That is it. And if you *have* a proof of *P → Q*, then you
can *apply* that proof/function to a proof of *P* to get a
proof of *Q*. That such a proof-converting function exists
shows that P implies Q! Indeed, we can see *andCommutes* as
a simple function, albeit one works on logical propositions
and proof objects, not ordinary data values such as strings
and Booleans. Here's an example.

```lean
def fiveIsTwoPlusThree : Prop := 5 = 2 + 3   -- a proposition
def p : fiveIsTwoPlusThree := rfl            -- a proof of it

def threeIsFiveMinusTwo : Prop := 3 = 5 - 2   -- another proposition
def q : threeIsFiveMinusTwo := rfl            -- a proof of it

def PimpQ : Prop := fiveIsTwoPlusThree → threeIsFiveMinusTwo  -- conjunction
def pimpq : PimpQ := fun pfP => q
```

### Iff (↔)

The *Iff (↔)* logical connective. P ↔ Q means that the
implication holds in both directions. We can express
this formally as (P → Q) ∧ (Q → P). P ↔ Q is equivalent
to (P → Q) ∧ (Q → P). Given two proofs, *pq : P → Q* and
*qp : Q → P*, *Iff.intro pq qp* constructs a proof of
*P ↔ Q*. In the other direction, if one assumed one has
a proof, (h : P ↔ Q), then (akin to And.left and And.right)
*h.mp : P → Q* and *h.mpr : Q → P*. Here *mp* is shorthand
for *modus ponens*, from the deductive logic of Aristotle.

Check it out. We'll assume we have proofs of both P → Q
and Q → P and we'll build a proof of P ↔ Q, then from
this proof we'll extract its left and right components,
which will be proofs of P → Q and Q → P in that order.

```lean
axiom ifpq : P → Q
axiom ifqp : Q → P

#check Iff.intro ifpq ifqp  -- yay, let's label that

def piffq : P ↔ Q := Iff.intro ifpq ifqp

#check piffq.mp   -- expect P → Q
#check piffq.mpr  -- expect Q → P
```
