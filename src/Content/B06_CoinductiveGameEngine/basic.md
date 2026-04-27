```lean
example : True := .intro
example : True := by
  exact True.intro

-- example : False := _

section examples

variable
  (P Q R : Prop)
  (p : P)
  (q : Q)
  (p2r : P → R)
  (q2r : Q → R)

inductive F : Prop where

--- AND

#check And
example : P ∧ Q :=
  And.intro p q

example : P ∧ Q := by
  refine (And.intro p q)

example : P ∧ Q → P :=
  (fun pf_p : P ∧ Q => pf_p.left)

example : P ∧ Q → P := by
  intro h
  exact h.left

--- OR

example : P ∨ Q := Or.inl p
example : P ∨ Q := Or.inr q

example : P ∨ Q := by exact Or.inl p
example : P ∨ Q := by exact Or.inr q

example : P ∨ Q → R :=
  (fun porq : P ∨ Q =>
    (
      match porq with
      | Or.inl p => p2r p
      | Or.inr q => q2r q
    )
  )

#check Or.elim

example : P ∨ Q → R := by
  intro h
  exact Or.elim h p2r q2r

example : P ∨ Q → R := by
  intro h
  cases h
  _


-- example : F := _

example : ¬F := fun f : F => nomatch f
example : ¬F := fun f : F => nomatch f







end examples
```
