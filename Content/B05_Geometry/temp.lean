/- @@@
## Inductive Predicates: Ev as a Running Example

`Ev n` is an inductively defined proposition that
holds when `n` is even. It has two constructors:
- `ev0`: 0 is even
- `step n pf`: if `n` is even then `n + 2` is even
@@@ -/

inductive Ev : Nat → Prop
| ev0 : Ev 0
| step : (n : Nat) → (evN : Ev n) → Ev (n + 2)

open Ev

-- Term-mode proof: build the evidence by hand
example : Ev 6 :=
  step
    (_)
    (step
      (_)
      (step
        (_)
        (ev0)))

-- Tactic-mode proof: let repeat do the work
example : Ev 100 := by
  repeat apply step
  exact ev0

/- @@@
### Extracting evidence from proofs

We can pattern match on an `Ev` proof to extract
the sub-proof it was built from.
@@@ -/

def extract {n : Nat} (nEv : Ev (n + 2)) : Ev n :=
  match nEv with
  | step _ evn2 => evn2

/- @@@
### Decidability: computing whether a property holds

`Decidable (Ev n)` produces either a proof of `Ev n`
or a proof of `¬ Ev n`. This lets `#eval` answer
yes/no questions about evenness.
@@@ -/

def giveMeProof : (n : Nat) → Decidable (Ev n)
| 0 => isTrue ev0
| 1 => isFalse (by intro h; cases h)
| n' + 2 =>
  match giveMeProof n' with
  | isTrue pf => isTrue (step n' pf)
  | isFalse npf => isFalse (by intro h; cases h with | step _ pf => exact npf pf)

#eval giveMeProof 6     -- isTrue ...
#eval giveMeProof 7     -- isFalse ...

/- @@@
## Elimination: What Can You Extract, and From Where?

A key question in dependent type theory: when can
you extract data (values in Type) from a term, and
when can you only extract proofs (values in Prop)?
The answer depends on what universe the type lives in.

### Extracting data from data (Type → Type): yes
@@@ -/

inductive Foo : Type where
| make (n : Nat) : Foo

example : Foo := Foo.make 3
example : Foo := Foo.make 4
example : Foo := Foo.make 5

-- Pattern match extracts the Nat: Type → Type ✓
def foo : Foo → Nat
| Foo.make n => n

/- @@@
### Extracting data from higher Type (Type 1 → Type): yes

Works in any computational universe.
@@@ -/

inductive Bar : Type 1 where
| make (n : Nat) : Bar

example : Bar := Bar.make 3
example : Bar := Bar.make 4
example : Bar := Bar.make 5

-- Type 1 → Type ✓
def bar : Bar → Nat
| Bar.make n => n

/- @@@
### Extracting data from a proof (Prop → Type): NO

Even though `Baz` wraps a `Nat`, because `Baz` lives
in `Prop`, Lean forbids extracting the `Nat`. Doing so
would violate proof irrelevance: all proofs of `Baz`
must be interchangeable, so the `Nat` inside cannot
matter computationally.
@@@ -/

inductive Baz : Prop where
| make (n : Nat) : Baz

example : Baz := Baz.make 3
example : Baz := Baz.make 4
example : Baz := Baz.make 5

-- Uncomment to see the error: Prop → Type ✗
-- def baz : Baz → Nat
-- | Baz.make n => n

/- @@@
### Extracting a proof from proof-carrying data (Type → Prop): yes

A structure in Type can carry proofs as fields.
We can always extract those proofs — going from
Type to Prop is fine.
@@@ -/

structure nEqN : Type where
  (n : Nat)
  (pf : n = n)

def nEq4 : nEqN := ⟨ 4, rfl ⟩

-- Extract the data: Type → Type ✓
def getN : nEqN → Nat := fun nen => nen.1
#eval getN nEq4

-- Extract the proof: Type → Prop ✓
def getPf : (ne : nEqN) → (ne.1 = ne.1) := fun ne => ne.2

/- @@@
### Summary of elimination rules

Where *data* are values of types in Type (Sort u, u > 0),
and *proofs* are values of types in Prop (Sort 0):

- **Prop → Prop**: extract proofs from proofs ✓
- **Type → Type**: extract data from data ✓
- **Type → Prop**: extract proofs from data ✓
- **Prop → Type**: extract data from proofs ✗ (proof irrelevance)
@@@ -/

/- @@@
## Existential Proofs as Dependent Pairs

To prove `∃ (x : α), P x`, you provide a *witness*
`a : α` and a *proof* that `P a` holds. The result
is a dependent pair `⟨a, h⟩` where the type of the
second component (`P a`) depends on the value of the
first (`a`). So `∃` is really a dependent pair type
living in `Prop`.
@@@ -/

-- An existence proof: there exists an even number
example : ∃ n, Ev n := ⟨4, step 2 (step 0 ev0)⟩

-- Another: there exists a number greater than 3
example : ∃ n, n > 3 := ⟨7, by omega⟩

/- @@@
Because `∃` lives in Prop, you cannot extract the
witness computationally — only use it in other proofs.
This is by design: proofs are irrelevant, so Lean
erases them at runtime.
@@@ -/

-- We can *use* an existence proof in another proof
-- by destructuring into witness and proof (∃ elimination)
example (h : ∃ n, Ev n) : ∃ m, Ev (m + 2) :=
  let ⟨n, pf⟩ := h       -- eliminate: get witness n and proof pf
  ⟨n, step n pf⟩          -- introduce: new witness n, new proof

-- The same elimination by tactic
example (h : ∃ n, Ev n) : ∃ m, Ev (m + 2) := by
  obtain ⟨n, pf⟩ := h    -- obtain destructures the ∃
  exact ⟨n, step n pf⟩

-- But we CANNOT extract data from it
-- def getWitness (h : ∃ n, Ev n) : Nat :=
--   let ⟨n, _⟩ := h    -- error: can't eliminate Prop into Type
--   n


#check Exists.elim

/- @@@
Exists.elim.{u}
  {α : Sort u}
  {p : α → Prop}
  {b : Prop}
  (h₁ : ∃ x, p x)
  (h₂ : ∀ (a : α), p a → b) :
  b
@@@ -/


inductive Dog where
| fido

axiom friendly : Dog → Prop
axiom small : Dog → Prop


example : (∃ d : Dog, friendly d ∧ small d) → (∃ d : Dog, small d) :=
fun pf =>
  (Exists.elim
    pf
    (fun w =>
      (fun pf =>
        (Exists.intro w pf.2)))
  )

/- @@@
## Sigma (Σ) Types

A Sigma type, `Σ (a : α), β a`, is the type of
*dependent pairs* `⟨a, b⟩` where `a : α` and the
type of `b` depends on the value of `a`. That is,
`b : β a`.

Think of it as a generalization of product types:
in `α × β` the second component's type is fixed,
but in `Σ (a : α), β a` it varies with `a`.

Sigma types have many uses:
- Existential witnesses (data-level ∃)
- Subset / subtype constructions
- Pre- and post-conditions on functions
- Bundling a value together with a proof about it

Dependent pairs come in three flavors depending on
which universe the components live in:

- `Σ (a : α), β a` — both components in Type. This
  is the standard Sigma type. You can freely extract
  and compute with both the first and second values.

- `{ a : α // P a }` (Subtype) — first component in
  Type, second in Prop. The value `a` is extractable
  and computable; the proof `P a` is erased at runtime
  but available for verification at type-checking time.

- `∃ (a : α), P a` — the whole thing lives in Prop.
  Both the witness and the proof are erased. You can
  use them in other proofs but never extract data from
  them. This is proof irrelevance at work.

The key intuition: moving from Σ to Subtype to ∃, you
trade computational access for logical abstraction.
@@@ -/

/- @@@
### Basic Sigma types: dependent pairs

The simplest use: pair a value with data that
depends on it. Here we pair a natural number `n`
with a vector (list of exactly `n` elements).
@@@ -/

-- A length-indexed vector type for illustration
inductive Vec (α : Type) : Nat → Type where
| nil  : Vec α 0
| cons : α → Vec α n → Vec α (n + 1)

-- A dependent pair: a number and a vector of that length
def threeBools : Σ n, Vec Bool n :=
  ⟨3, Vec.cons true (Vec.cons false (Vec.cons true Vec.nil))⟩

-- We can project out the components
#check threeBools.1   -- 3 : Nat
#check threeBools.2   -- Vec Bool 3

/- @@@
### Bundling a value with a proof about it

Since `Ev n : Prop`, we can't use `Σ` directly (it
requires both components in `Type`). Instead we use
`Subtype`: `{ n : Nat // Ev n }` bundles a natural
number with a proof that it's even. Unlike `∃` (which
lives in Prop and erases the witness), the subtype
lives in Type so we can compute with the witness.
@@@ -/

-- The Subtype type is really just a Sigma type
-- { n : Nat // Ev n } is notation for Subtype (fun n => Ev n)
-- Subtype is defined as a structure with two fields:
--   (val : α) and (property : p val)
def anEvenNumber' : Subtype (fun n => Ev n) := ⟨6, step 4 (step 2 (step 0 ev0))⟩

-- Using the notation:
def anEvenNumber : { n : Nat // Ev n } := ⟨6, step 4 (step 2 (step 0 ev0))⟩

-- We can compute with the witness
#eval anEvenNumber.val      -- 6

-- And we can use the proof
#check anEvenNumber.property     -- Ev 6

/- @@@
### Subtypes: a special case of Sigma

Lean's `Subtype` (notation `{ x : α // p x }`) is
essentially `Σ (x : α), p x` but living in Type even
though `p x : Prop`. It bundles a value with a proof
of a property. The proof part is erased at runtime.
@@@ -/

-- The type of natural numbers greater than zero
def posNat := { n : Nat // n > 0 }

-- Constructing a value of a subtype
def five : posNat := ⟨5, by omega⟩

-- Projecting out the value and the proof
#eval five.val          -- 5
#check five.property    -- 5 > 0

/- @@@
### Preconditions: requiring properties of inputs

Use Sigma / Subtype to express preconditions on
function inputs. The caller must provide a proof
that the input satisfies the requirement.
@@@ -/

-- Division that requires a nonzero divisor
def safeDiv (n : Nat) (d : { k : Nat // k > 0 }) : Nat :=
  n / d.val

#eval safeDiv 10 ⟨3, by omega⟩    -- 3
-- #eval safeDiv 10 ⟨0, by omega⟩ -- won't typecheck: 0 > 0 is false

/- @@@
### Postconditions: guaranteeing properties of outputs

A function returning `{ r : α // P r }` guarantees
that its output satisfies property `P`. The proof
is constructed inside the function body.
@@@ -/

-- A function that doubles a number and proves the result is even
def double (n : Nat) : { m : Nat // Ev m } :=
  ⟨2 * n, by
    induction n with
    | zero => exact ev0
    | succ n' ih =>
      show Ev (2 * n' + 2)
      exact step (2 * n') ih⟩

#eval (double 5).val        -- 10
#check (double 5).property  -- Ev 10

/- @@@
### Pre- and post-conditions together

Combine both patterns: require something of the
input and guarantee something about the output.
@@@ -/

-- Predecessor that requires n > 0 and guarantees result + 1 = n
def safePred (n : { k : Nat // k > 0 }) :
    { m : Nat // m + 1 = n.val } :=
  ⟨n.val - 1, by omega⟩

#eval (safePred ⟨5, by omega⟩).val     -- 4

/- @@@
### Summary

| Pattern                       | Type                              |
|-------------------------------|-----------------------------------|
| Dependent pair                | `Σ (a : α), β a`                 |
| Data-level existential        | `Σ (x : α), P x`                |
| Subtype (value + proof)       | `{ x : α // P x }`              |
| Precondition on input         | `(x : { a : α // Pre a }) → β`  |
| Postcondition on output       | `α → { b : β // Post b }`       |
| Pre + post                    | `{ a // Pre a } → { b // Post b }` |

Key distinction: `Σ` lives in `Type` (you can compute
with both components). `∃` lives in `Prop` (the witness
is erased — you can only use it in proofs).
@@@ -/
