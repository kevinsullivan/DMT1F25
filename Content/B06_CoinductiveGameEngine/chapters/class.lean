example : ∀ (n m : Nat), n + m = n + m :=
  fun (n m : Nat) => rfl


example : ∀ (n m : Nat), n + m = n + m := by
intro x y
exact rfl

example : ∀ (n m : Nat), n + m = m + n := by
intro x y

#check Nat.add
