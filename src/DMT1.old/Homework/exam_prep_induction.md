```lean
/- ***
WORK IN PROGRESS: NOT READY TO STUDY

## Section 10: Induction (Recursors)
New concept: induction via recursors for inductive types.

### Basic: using recursors for `Bool`, `Nat`, and `List`
Practice using the elimination/recursion principles:
* `Bool.rec` for case analysis on booleans
* `Nat.rec` for natural number induction
* `List.rec` for list induction

### Mixed: combining induction with all previous connectives
Use induction together with `→`, `∧`, `∨`, `True`, `False`, `¬`, `↔`, `∀`, `∃`, and `Eq`
to prove properties about inductive data types.
***-/

/-- Basic 10.1: prove a property holds for all booleans by cases. -/
theorem bool_basic_1 : ∀ b : Bool, b = true ∨ b = false :=
  fun b => Bool.rec (Or.inr rfl) (Or.inl rfl) b

/-- Basic 10.2: double negation of a boolean equals itself. -/
theorem bool_basic_2 : ∀ b : Bool, !!b = b :=
  fun b => Bool.rec rfl rfl b

/-- Basic 10.3: addition of zero on the right (by induction). -/
theorem nat_basic_1 : ∀ n : Nat, n + 0 = n :=
  fun n => Nat.rec
    rfl
    (fun k ih => match ih with | rfl => rfl)
    n

/-- Basic 10.4: addition of successor. -/
theorem nat_basic_2 : ∀ n m : Nat, n + m.succ = (n + m).succ :=
  fun n m => Nat.rec
    rfl
    (fun k ih => match ih with | rfl => rfl)
    n

/-- Basic 10.5: zero is left identity for addition. -/
theorem nat_basic_3 : ∀ n : Nat, 0 + n = n :=
  fun n => rfl

/-- Basic 10.6: successor distributes over addition (left). -/
theorem nat_basic_4 : ∀ n m : Nat, n.succ + m = (n + m).succ :=
  fun n m => Nat.rec
    rfl
    (fun k ih => match ih with | rfl => rfl)
    m

/-- Basic 10.7: list append with nil on the right. -/
theorem list_basic_1 {α : Type u} : ∀ l : List α, l ++ [] = l :=
  fun l => List.rec
    rfl
    (fun h t ih => match ih with | rfl => rfl)
    l

/-- Basic 10.8: list append with nil on the left. -/
theorem list_basic_2 {α : Type u} : ∀ l : List α, [] ++ l = l :=
  fun l => rfl

/-- Basic 10.9: list reversal of singleton. -/
theorem list_basic_3 {α : Type u} : ∀ (a : α), [a].reverse = [a] :=
  fun a => rfl

/-- Mixed 10.9: proving conjunction of properties by induction. -/
theorem nat_mixed_1 (P Q : Nat → Prop)
    (hP0 : P 0) (hQ0 : Q 0)
    (hPs : ∀ n, P n → P n.succ)
    (hQs : ∀ n, Q n → Q n.succ) :
    ∀ n : Nat, P n ∧ Q n :=
  fun n => Nat.rec
    ⟨hP0, hQ0⟩
    (fun k ih => ⟨hPs k ih.left, hQs k ih.right⟩)
    n

/-- Mixed 10.10: implication between properties preserved by induction. -/
theorem nat_mixed_2 (P Q : Nat → Prop)
    (h0 : P 0 → Q 0)
    (hs : ∀ n, (P n → Q n) → (P n.succ → Q n.succ)) :
    ∀ n : Nat, P n → Q n :=
  fun n => Nat.rec h0 hs n

/-- Mixed 10.11: existence proofs by induction. -/
theorem nat_mixed_3 : ∀ n : Nat, n = 0 ∨ ∃ m : Nat, n = m.succ :=
  fun n => Nat.rec
    (Or.inl rfl)
    (fun k _ => Or.inr ⟨k, rfl⟩)
    n

/-- Mixed 10.12: universal quantification over lists by induction. -/
theorem list_mixed_1 {α : Type u} (P : List α → Prop)
    (h_nil : P [])
    (h_cons : ∀ h t, P t → P (h :: t)) :
    ∀ l : List α, P l :=
  fun l => List.rec h_nil h_cons l

/-- Mixed 10.13: biconditional by boolean case analysis. -/
theorem bool_mixed_1 : ∀ b : Bool, (b = true ↔ b ≠ false) :=
  fun b => Bool.rec
    ⟨fun h => fun eq => match h with, fun _ => rfl⟩
    ⟨fun _ neq => rfl, fun h => fun eq => match eq with⟩
    b

/-- Mixed 10.14: list decomposition. -/
theorem list_mixed_2 {α : Type u} : ∀ l : List α, l = [] ∨ ∃ h t, l = h :: t :=
  fun l => List.rec
    (Or.inl rfl)
    (fun h t _ => Or.inr ⟨h, t, rfl⟩)
    l

/-- Mixed 10.15: commutativity of addition. -/
theorem nat_mixed_4 : ∀ m n : Nat, m + n = n + m :=
  fun m n => Nat.rec
    (nat_basic_1 m).symm
    (fun k ih =>
      have h1 : m + k.succ = (m + k).succ := nat_basic_2 m k
      have h2 : k.succ + m = (k + m).succ := nat_basic_4 k m
      match ih with | rfl => h1.trans h2.symm)
    n

/-- Mixed 10.16: associativity of addition by induction. -/
theorem nat_mixed_5 : ∀ a b c : Nat, (a + b) + c = a + (b + c) :=
  fun a b c => Nat.rec
    rfl
    (fun _ ih => match ih with | rfl => rfl)
    c

/-- Mixed 10.17: De Morgan for booleans by case analysis. -/
theorem bool_mixed_2 : ∀ a b : Bool, !(a && b) = (!a || !b) :=
  fun a b => Bool.rec
    (Bool.rec rfl rfl b)
    (Bool.rec rfl rfl b)
    a

/-- Mixed 10.18: distributivity of multiplication over zero. -/
theorem nat_mixed_6 : ∀ n : Nat, n * 0 = 0 :=
  fun n => Nat.rec
    rfl
    (fun k ih => ih)
    n

/-- Mixed 10.19: list append associativity. -/
theorem list_mixed_3 {α : Type u} :
    ∀ l₁ l₂ l₃ : List α, (l₁ ++ l₂) ++ l₃ = l₁ ++ (l₂ ++ l₃) :=
  fun l₁ l₂ l₃ => List.rec
    rfl
    (fun h t ih => match ih with | rfl => rfl)
    l₁

/-- Mixed 10.20: boolean equivalences. -/
theorem bool_mixed_3 (P : Bool → Prop) :
    (P true ∧ P false) ↔ (∀ b, P b) :=
  ⟨fun ⟨pt, pf⟩ b => Bool.rec pf pt b,
   fun h => ⟨h true, h false⟩⟩

/-- Mixed 10.21: strong property by induction. -/
theorem nat_mixed_7 (P : Nat → Prop) :
    P 0 → (∀ n, P n → P n.succ) → ∀ n, P n :=
  fun h0 hs n => Nat.rec h0 hs n

/-- Mixed 10.22: length properties by induction. -/
theorem list_mixed_4 {α : Type u} : ∀ l : List α, l.length = l.length :=
  fun l => rfl

/-- Mixed 10.23: proving negation by induction. -/
theorem nat_mixed_8 : ∀ n : Nat, ¬(n.succ = 0) :=
  fun n eq => match eq with

/-- Mixed 10.24: disjunction property by induction. -/
theorem nat_mixed_9 : ∀ n : Nat, n = 0 ∨ n ≠ 0 :=
  fun n => Nat.rec
    (Or.inl rfl)
    (fun k _ => Or.inr (fun h => match h with))
    n

/-- Mixed 10.25: list length and cons relationship. -/
theorem list_mixed_5 {α : Type u} :
    ∀ (h : α) (t : List α), (h :: t).length = t.length.succ :=
  fun h t => rfl
```
