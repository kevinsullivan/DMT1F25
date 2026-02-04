```lean
theorem emImpLaw { P Q S : Prop} :
  (∀ S, S ∨ ¬S) →  (¬(P ∧ Q) → ¬P ∨ ¬Q) :=
_


/-
- ¬(A ∧ B) ↔ ¬A ∨ ¬B
  - ¬(A ∧ B) → ¬A ∨ ¬B

  - ¬A ∨ ¬B → ¬(A ∧ B)
- ¬(A ∨ B) ↔ ¬A ∧ ¬ B
-/

example { A B : Prop } : ¬(A ∧ B) ↔ ¬A ∨ ¬B :=
Iff.intro
  (
    /-
      A B : Prop
      ⊢ ¬(A ∧ B) → ¬A ∨ ¬B
    -/
    fun h => Or.inl _ -- STUCK
    /-
      A B : Prop
      h : ¬(A ∧ B)
      ⊢ ¬A ∨ ¬B
    -/
  )
  (
    _
  )

axiom em : ∀ (P : Prop), P ∨ ¬P

example { A B : Prop } : (¬(A ∧ B) ↔ ¬A ∨ ¬B) :=
Iff.intro
(
  fun h =>
  (
    let emA := em A
    let emB := em B
    match emA with
    | Or.inl a =>
      match emB with
      | Or.inl b => False.elim (h (And.intro a b))
      | Or.inr nb => Or.inr nb
    | Or.inr na => Or.inl na
  )
)
(
  _
)
```
