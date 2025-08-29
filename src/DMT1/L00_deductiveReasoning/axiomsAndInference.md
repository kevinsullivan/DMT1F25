# Deductive Reasoning : The Case of Conjunction
```lean
namespace DMT1.L00_reasoning
```

## Propositions

Assume that P, Q, and R are arbitrary propositions.
Another name for an assumption accepted with proof is
an *axiom*. This is correct basic lingo in mathematics.
We can express axioms in Lean using the *axiom* keyword.
```lean
axiom P : Prop      -- assume P is a proposition
axiom Q : Prop      -- assume Q is a proposition
axiom R : Prop      -- assume R is a proposition

#check P            -- ask Lean what type of thing is P?
#check 5            -- for data, too: 5 is a Nat
#check "Hello!"     -- for any type of data
```

With P, Q, and R accepted axiomatically as propositions,
we can form larger ones by combining these existing ones
using *And* as a proposition building function, or, in
logical lingo, a connective. *And* takes two propositions
as arguments and yields the conjunction of the two, itself
a proposition.

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

end DMT1.L00_reasoning
```
