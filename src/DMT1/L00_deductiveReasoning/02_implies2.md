# Implication (→)

<!-- toc -->


```lean
namespace ImplicationInference
```

In everyday logic the `→` connective represents a conditional statement,
asserting that if some proposition, call it *P*, is true, then some other
proposition, *Q*, must be true as well. We call this an *implication* and
write it as `P → Q`. his section explains this form of logical proposition,
its inference rules, and includes examples of theorems provable from the rules.

## Example: Reactor Safety

Mathematical logic gives us concepts and notations we can use to represent
and analyze interesting worlds. We map natural-language descriptions into
formal propositions and then reason deductively about those worlds.

Consider a reactor safety requirement: if the temperature is too high, the
shutdown sequence must be initiated. We model these as propositional
variables and then form the implication `HighTemp → ShutdownStarted`.

```lean
axiom HighTemp : Prop           -- temperature is too high
axiom ShutdownStarted : Prop    -- shutdown sequence initiated

#check (HighTemp → ShutdownStarted)   -- it's a Prop
```

## The → Proposition Builder

More generally, if `P` and `Q` are arbitrary propositions, then `P → Q`
(read “if `P` then `Q`”) is also a proposition.

```lean
axiom P : Prop
axiom Q : Prop
#check P → Q
```

## Inference Rules

The rules for `→` capture the intended meaning: if `P` is true then `Q` is
true. In constructive type theory (Lean), a proof of `P → Q` *is* a function
that transforms any proof `p : P` into a proof `q : Q`.

We present the rules with explicit hypothesis names and explicit proof
constructions in the conclusions.

````
-- Introduction (→.intro)

 Γ ⊢ qOf : fun (p : P) => Q
--------------------------- →.intro
    Γ ⊢ qOf : P → Q
````

Assumptions are above the line, the name of the
inference rule is to the right, and the conclusion
is below. What this rule then says is that if you
have or can define a lambda abtraction (which is
to say a function) from P to Q, then you can
clude that P implies Q (P → Q). The reasoning is
that if there's such a function, then any proof
of P can be converted into a proof of Q; so, if
P has a proof, so does Q, obtained by applying *h*
to *p*.


````
-- Elimination / Modus Ponens (→.elim)

  Γ ⊢ h : P → Q      Γ ⊢ p : P
-------------------------------- →.elim
          Γ ⊢ (h p) : Q
````

## Examples

### Reactor Safety

Suppose we know both that high temperature implies
shutdown (f : HighTemp → ShutdownStarted), and that
the temperature is high (h : HighTemp). Then (f h)
applies the implication to a proof of the premise
to derive a proof of the conclusion. In short, to
*use* a proof of an implication, apply it to any
proof of its premise to derive a proof of its
conclusion.

````
Γ ⊢ f : HighTemp → ShutdownStarted     Γ ⊢ h : HighTemp
------------------------------------------------------- →.elim
            Γ ⊢ f h : ShutdownStarted
````

```lean
axiom h : HighTemp
axiom f : HighTemp → ShutdownStarted
#check (f h) -- function application produces a proof of ShutdownStarted
```

### Rain → Wet → Slippy

Let Rain, Wet, and Slippy be propositions for:

- “it’s raining,”
- “the street is wet,” and
- “the street is slippy.”

Also assume that we know the following:

- rtow : Rain → Wet
- wtos : Wet → Slippy,
- rain : Rain.

We can prove under these conditions that the roads
are Slippy. Challenge to you: Do it right now in your
head. Formally it's done by by chaining implications
via →.elim.

```lean
axiom Rain : Prop
axiom Wet : Prop
axiom Slippy : Prop

axiom rtow : Rain → Wet
axiom wtos : Wet → Slippy
axiom rain : Rain

#check
let wet := rtow rain    -- modus ponens (→ elims)
let slippy := wtos wet  -- modus ponens (→ elim)
slippy                  -- conclusion : Slippy

#check wtos (rtow rain)
```

## Theorems

From the inference rules for → we can derive proofs
that → has important properties not explicit in the
axioms (inference rules). Here we will state and prove
that → is reflexive and → is transitive.

### Implication (→) is Reflexive

For any proposition P, we have P → P. The proof term is the identity
function on proofs of P.

````
    (no hypotheses)
--------------------------- →.intro
Γ ⊢ (fun (p : P) => p) : P → P
````

```lean
theorem refl (P : Prop) : P → P :=
fun p => p
```

### Implication (→) is Transitive

From proofs of P → Q and Q → R, we obtain a proof of P → R by composing
the functions.

````
Γ ⊢ f : P → Q      Γ ⊢ g : Q → R
------------------------------------
Γ ⊢ (fun (p : P) => g (f p)) : P → R
````

```lean
-- A more verbose, step-by-step construction
theorem trans
{P Q R : Prop} : (P → Q) → (Q → R) → (P → R)
| pq, qr => fun (p : P) =>
  let q := pq p
  let r := qr q
  r

-- Another concise proof
theorem trans' {P Q R : Prop} : (P → Q) → (Q → R) → (P → R) :=
  fun pq qr => fun p => qr (pq p)
```

## Applying General Theorems to Particulars

Great theorems are powerful because they are
general. Here, it doesn't matter *what* proposition
P, Q, and R are; the theorem is always true. It's a
theorem! It's *valid*. The power comes from knowing
that you can *apply* a general theorem in any specific
situation that matches its conditions.

For example, our statement that → is transitive starts
with *for any propositions, P, Q, R.* Now if you want
to apply this theorem to the special case of our little
weather world, just *apply* it! It's first three arguments
are propositions (implicit and inferred from the remaining
arguments).

Let's see what happens when we apply it to our three
specific propositions, Rain, Wet, and Slippy.

```lean
#check (@trans Rain Wet Slippy)
```

If you put your cursor right at the right parenthesis
Lean will tell you the type of the resulting term: It's
the general theorem, *(P → Q) → (Q → R) → (P → R)* but
now *specialized* by the substitution (by β reduction)
of our three particular types, Rain, Wet, and Slippy,
for the formal parameters of the theorem, giving a term
of type *(Rain → Wet) → (Wet → Slippy) → Rain → Slippy*.
If we now apply that function to proofs of (Rain → Wet)
and (Wet → Slippy) we get back a proof of (Rain → Slippy).

```lean
-- A proof of Rain → Slippy computed by applying theorem
#check (@trans Rain Wet Slippy) rtow wtos

-- Of course applying this to proof of rain proves slippy

#check @trans Rain Wet Slippy rtow wtos rain  -- Slippy!
```


## Summary: → rules and  theorems

Given P Q R : Prop.

-  →.intro : To prove P → Q, provide a function (fun (p : P) => q : Q).
-  →.elim : From h : P → Q and p : P, infer h p : Q (modus ponens).

Derived theorems:

- refl : P → P
- trans : (P → Q) → (Q → R) → (P → R)

Key idea: We can *apply* general theorems, once we have them,
to derive proofs of special cases. This is the huge power of
mathematics. We construct enormous libraries of highly general
theorems, then we can apply them all over the place without
having to re-prove them for each particular special case.

```lean
end ImplicationInference
```
