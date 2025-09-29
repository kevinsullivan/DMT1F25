**# Logical Connectives in Lean**
Below are the *canonical introductions/eliminations*
(constructors and extractors) Lean provides for each
connective/type in predicate logic (as it's embedded
in Lean), stated as term signatures. These types line
up with natural-deduction inference rules (a relation
known as the Curry-Howard Correspondence).
---
**## ⊤ (True) and ⊥ (False)**
- (⊤ intro) `True.intro : True`
- (⊥ elim) `False.elim : False → α` -- ex falso quodlibet
---
**## ∧ (conjunction)**
- (intro) `And.intro : P → Q → P ∧ Q`
- (elim₁) `And.left : P ∧ Q → P`
- (elim₂) `And.right : P ∧ Q → Q`
- (elim) `And.elim : P ∧ Q → (P → Q → R) → R` -- `And.rec` in Lean
---
**## → (implication)**
- (intro) `λ : (P → Q)` is formed by `fun (_ : P) => ... : Q`
- (elim) `app : (P → Q) → P → Q` (function application)
---
**## ∀ (universal quantifier)**
In Lean, → is notation for ∀ when the codomain is Prop. Lambda abstractions
define (total) functions. The upshot is that the rules are identical to →.
- (intro) `Forall.intro : (∀ x, P x)` is `fun x => ... : P x`
- (elim) `Forall.elim : (∀ x, P x) → P a` -- specialization (application)
---
**## ↔ (iff / bi-implication)**
- (intro) `Iff.intro : (P → Q) → (Q → P) → (P ↔ Q)`
- (elim→) `Iff.mp : (P ↔ Q) → P → Q` -- modus ponens
- (elim←) `Iff.mpr : (P ↔ Q) → Q → P` -- modus ponens reversed
---
**## ∨ (disjunction)**
- (intro₁) `Or.inl : P → P ∨ Q`
- (intro₂) `Or.inr : Q → P ∨ Q`
- (elim) `Or.elim : P ∨ Q → (P → R) → (Q → R) → R`
---
**## ¬ (negation)**
- (def) `Not P := P → False`
- (intro) derive `P → False` by showing P leads to contradiction
- (elim) `not_elim : ¬P → P → False` -- by application
---
**## ∃ (existential quantifier)**
- (intro) `Exists.intro : ∀ {α} {p : α → Prop} (w : α), p w → ∃ x, p x`
- (elim) `Exists.elim : (∃ x, p x) → (∀ w, p w → R) → R` -- aka `Exists.rec`

Note: Dependent pattern matching lets you prove theorems,
not just compute values, because the conclusion type
can vary with the case. This is key to induction
principles: the "motive" captures the statement you
want to prove about all cases, and the eliminator
gives you a way to reduce proofs about arbitrary
values to proofs about base cases.
---
**## = (propositional equality)**
Fundamental axioms only:
- (refl) `rfl` / `Eq.refl : a = a`
- (rec) `Eq.rec : {motive : α → Sort u} → a = b → motive a → motive b`

Note: `Eq.rec` is the dependent eliminator. `Eq.subst`, `Eq.symm`, `Eq.trans`,
`congrArg`, `congrArg2`, and all other equality principles are theorems
derivable from these two axioms.
---
**## Additional Axioms (Classical & Extensional)**
These axioms extend Lean's constructive core with classical reasoning
and extensionality principles. Use `#print axioms <theorem>` to check dependencies.

**### Propositional Extensionality**
- `propext : (a ↔ b) → a = b`
  - Logically equivalent propositions are equal
  - Enables extensional treatment of propositions
  - Essential for set theory (sets as predicates)

**### Quotient Types**
- `Quot.mk : {r : α → α → Prop} → α → Quot r` -- quotient constructor
- `Quot.lift : {r : α → α → Prop} {β : Sort v} → (f : α → β) →
    (∀ a b, r a b → f a = f b) → Quot r → β`
- `Quot.ind : {r : α → α → Prop} {motive : Quot r → Prop} →
    (∀ a, motive (Quot.mk r a)) → ∀ q, motive q`
- `Quot.sound : {r : α → α → Prop} → r a b → Quot.mk r a = Quot.mk r b`
  - Quotient types identify elements related by an equivalence relation
  - `Quot.sound` is the key axiom: related elements have equal quotients

**### Function Extensionality**
- `funext : (∀ x, f x = g x) → f = g`
  - Functions equal pointwise are equal
  - Provable from quotient types (not an independent axiom)
  - Essential for reasoning about function equality

**### Classical Choice & Law of Excluded Middle**
Located in the `Classical` namespace:
- `Classical.choice : Nonempty α → α`
  - Extracts a witness from a nonempty type
  - Requires `open Classical` to use
  - Enables non-constructive reasoning

- `Classical.em : ∀ (p : Prop), p ∨ ¬p` -- law of excluded middle
  - Provable from `choice`, `propext`, and `Quot.sound` (Diaconescu's theorem)
  - Enables proof by contradiction and case analysis
  - Also in `Classical` namespace

**Note on Constructive vs Classical:**
Without opening `Classical`, Lean remains constructive (intuitionistic).
The axioms `propext` and `Quot.sound` are used pervasively even in
constructive developments. Only `Classical.choice` and its consequences
(like `em`) require explicitly opting into classical reasoning.
---
**## Computational (Non-Prop) dependent pairs**
**### Prod (α × β) — non-dependent pair (Type level)**
- (intro) `Prod.mk : α → β → α × β`
- (proj₁) `Prod.fst : α × β → α`
- (proj₂) `Prod.snd : α × β → β`
- (rec) `Prod.rec : (α → β → R) → α × β → R`

**### Σ (Sigma: dependent pair)**
- (intro) `Sigma.mk : (a : α) → β a → Σ x, β x`
- (proj₁) `Sigma.fst : (Σ x, β x) → α`
- (proj₂) `Sigma.snd : (u : Σ x, β x) → β u.fst`
- (elim) `Sigma.elim : (Σ x, β x) → (∀ x, β x → R) → R` -- aka `Sigma.rec`
---
**## Notes on usage in Lean**
- Many "intro" rules are just lambda terms; many "elim" rules are just application.
- `rec`/`elim` forms are the single-step eliminators/induction principles
  generated automatically by `inductive` definitions.
- `Exists` (∃) is a *Prop-valued* dependent pair; `Sigma` (Σ) is *Type-valued*.
- `And` (∧) is non-dependent pairing at the *Prop* level; `Prod` (×) is its *Type* analogue.
- Built-in primitives: `→`, `∀`, `Sort`, `Prop`, `Type` are part of the core calculus.
- Inductive types: `True`, `False`, `And`, `Or`, `Exists`, `Eq` are defined inductively.
- The Curry-Howard correspondence: propositions as types, proofs as terms,
  implication as function types, universal quantification as dependent function types.
- For equality: only `Eq.refl` and `Eq.rec` are fundamental axioms; all other equality
  principles are derived theorems.
