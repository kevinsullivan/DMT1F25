# Reasoning in Action: The Case of Conjunction
```lean
namespace DMT1.reasoning
```

## Propositions

Assume that P, Q, and R are arbitrary propositions.
```lean
axiom P : Prop
axiom Q : Prop
axiom R : Prop

#check P
#check 5
#check "Hello, World!"
-- #check Z
```

From these elementary propositions we can form larger
propositions by combining the existing ones using what
we call logical connective operators, or connectives.
One of these connectives is *And*. As a function, it
takes two propositions as arguments and yields a new
proposition in which the two given ones are *conjoined*.

```lean
#check And P Q
```

In everyday logical writing, instead of writing *And* in
front of its its two arguments, as in *And P Q* we use ∧
as a shorter *infix* notation for *And* and write *P ∧ Q*.

```lean
#check P ∧ Q
```

In Lean, propositions are objects, like ordinary values,
to which we can give names. Here, to the name *PandQ* that
we just made up, we can bind the proposition, P ∧ Q as a
value.

```lean
def PandQ := And P Q
#check PandQ
#reduce (types := true) PandQ
```


### Proofs of Propositions

We've already discussed proofs. Let's now assume that we have
a few and see what we can do with them.

Next assume that we have proof objects, p, q, and r:
proofs the propositions, P, Q, and R, respectively.

```lean
axiom p : P
axiom q : Q
axiom r : R

#check P
#check p
```

### Logical Connectives: The Case of And (∧)

We've seen that from a few elementary
propositions we can form an endless realm
of compound propositions. Of course we want
to be able to prove them, too (when they're
true).

Just as logical *connectives* compose given
propositions into larger propositions, so we
also have "little programs" for composing proofs
of given propositions into proofs of larger ones
made from them.

As an example, consider this. So far we have:

- *P* and *Q* are propositions
- because they are, so is P ∧ Q
- *p* and *q* are proofs of P, Q
- And.intro is a function
  - in: (P Q : Prop) (p : P) (q : Q)
  - out: (And.intro p q) : P ∧ Q
- notation: for And.intro p q, ⟨ p, q ⟩



```lean
-- Two ways of writing the same concept
def pq :    P ∧ Q    :=  And.intro p q
def pq' :   P ∧ Q    :=  ⟨ p, q ⟩


-- nested proofs in this case for nested propositions
def p_qr :  P ∧ (Q ∧ R)  :=  And.intro p (And.intro q r)
def p_qr' :  P ∧ (Q ∧ R)  :=  ⟨ p, ⟨ q, r ⟩ ⟩

-- nesting in the other order
def pq_r :  (P ∧ Q) ∧ R  :=  And.intro (And.intro p q) r
def pq_r' :  (P ∧ Q) ∧ R  :=  ⟨ ⟨ p, q ⟩, r ⟩
```

### Deconstructing Proof Objects

And just as we have ways of using proofs of smaller
propositions in the construction of proofs of larger
propositions composed from the smaller ones, so we
have ways to take apart larger proofs into component
elements. For example, from a proof, ⟨ p, q ⟩ of P ∧ Q
we should be able to "logically deduce, haha" a proof,
(p : P). Yeah, it's just the first element of the pair
of proofs that proves P ∧ Q.

```lean
#check pq.left
#check pq.right
#check p_qr
#check pq_r
#check pq_r.right
#check pq_r.left
#check pq_r.left.left
#check pq_r.left.right
```

## Theorems!

The combination of primitive programs both for putting
proofs together and for taking them apart means that we
can prove truly deep and interesting results, where the
very concepts being proved are fundamental across all of
mathematics.

### Conjunction (And, ∧) is Commutative

When we say that a binary operation, such as ∧, commutes,
or is commutative, we mean that changing the order of the
operands never changes the meaning of an expression. Here,
we nean that for any proposition, P, Q, if you have a proof
that shows P ∧ Q is true you can always convert it into one
showing Q ∧ P is true. In short P ∧ Q → Q ∧ P (and it works
in the other direction, too.)

```lean
theorem andIsCommutative : P ∧ Q → Q ∧ P :=
  fun (h : P ∧ Q) =>    -- given a proof of P and Q
    And.intro           -- construct a proof from
      (And.right h)     -- (q : Q)
      (And.left h)      -- (p: P), in that order, voila!

-- Here it is using shorthand notation
theorem andIsCommutative' : P ∧ Q → Q ∧ P :=
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
theorem andIsCommutative'' : P ∧ Q → Q ∧ P :=
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
theorem andAssoc : P ∧ Q ∧ R ↔ (P ∧ Q) ∧ R :=
  -- to prove ↔, prove both directions
  Iff.intro
  (
    fun
    (h : P ∧ Q ∧ R) =>
    (
      _
    )
  )
  (
    fun
    (h : (P ∧ Q) ∧ R) =>
    (
      _
    )
  )
  -- { -- forward: P ∧ Q ∧ R → (P ∧ Q) ∧ R
  --   intro h                   -- assumption
  --   let p := h.left           -- get smaller proofs
  --   let q := h.right.left
  --   let r := h.right.right
  --   let pq := And.intro p q   -- assumble and retirn
  --   exact (And.intro pq r)    -- the final proof object
  -- }
  -- { -- reverse: (P ∧ Q) ∧ R → P ∧ Q ∧ R
  --   -- the same basic approach applies here
  --   intro h
  --   let p := h.left.left
  --   let q := h.left.right
  --   let r := h.right
  --   let qr := And.intro q r
  --   exact (And.intro p qr)
  -- }



theorem andAssoc' : P ∧ Q ∧ R ↔ (P ∧ Q) ∧ R :=
  -- to prove ↔, prove both directions
  Iff.intro
    ( by -- forward: P ∧ Q ∧ R → (P ∧ Q) ∧ R
      intro h                   -- assumption
      let p := h.left           -- get smaller proofs
      let q := h.right.left
      let r := h.right.right
      let pq := And.intro p q   -- assumble and retirn
      exact (And.intro pq r)    -- the final proof object
    )
    ( by -- reverse: (P ∧ Q) ∧ R → P ∧ Q ∧ R
    -- the same basic approach applies here
    intro h
    let p := h.left.left
    let q := h.left.right
    let r := h.right
    let qr := And.intro q r
    exact (And.intro p qr)
    )
```

## Wrap Up: New Ideas

### Implies (→)

You can read the proposition, P → Q, as asserting that
*if P is true then so is Q.* Now this question is what
proves this kind of proposition to be true. Here's the
idea. Assume P is true, with a proof p. Now show that
from that p you can construct a proof of Q. That shows
that if P is true (with a proof p) then Q is true, too,
as it's always possible to derive a proof of Q using p.

So that's how you construct a proof of P → Q: just give
a way to convert any proof of P into a proof of Q. That
is it. The resulting proof, in our logic, will then be
*literally* in the form of a function that turns a proof
of P given as an argument into a proof of Q as a return
value. In other words, you can then *apply* a proof of
*P → Q* to a proof *(p : P)* and the return value will
be a proof of *Q*. That such a proof-converter exists
shows that P implies Q! Indeed, we *andCommutes* can be
seen now as a simple function definition, albeit one that
acts on proof objects, not ordinary data values such as
strings and Booleans.

### Iff (↔)

The *Iff (↔)* logical connective. P ↔ Q simple means
(P → Q) ∧ (Q → P). To prove P ↔ Q you thus need to have
both a proof of P → Q and a proof of Q → P. That's it.
Moreover, if you have a proof of P ↔ Q then from it you
can always extract a proof P → Q and a proof of Q → P.

```lean
end reasoning
```
