/-!
# True

True is a proposition that's always true, because there is
always a proof of it, namely *True.intro.* A proof of True
gives you no new information. So there is no elimination
rule for True.
-/

namespace Alpha.book1lib.chapters.C01_true

/-!
## The Proposition True

In Lean, `True` is a proposition (of type `Prop`) that is
defined to have exactly one proof: `True.intro`. Because
there's always a proof available, `True` is always true.

This might seem trivial, but it serves important roles:
- As a base case in logical constructions
- As the "default" or "trivial" proposition
- In conditional expressions where a condition is always met
-/

#check True         -- True : Prop
#check True.intro   -- True.intro : True

/-!
## Introduction Rule

There is exactly one way to prove `True`: use `True.intro`.
-/

/-!
```
------------------- True-intro
Γ ⊢ True.intro : True
```
-/

/-!
No premises are needed. You can always produce a proof of True.
-/

example : True := True.intro

-- Alternative notation using anonymous constructor
example : True := ⟨⟩

/-!
## No Elimination Rule

There is no elimination rule for `True`. Why? Because a proof
of `True` carries no information. Knowing that `True` is true
tells you nothing new about the world.

Compare with `And`: from a proof of `P ∧ Q`, you can extract
proofs of `P` and `Q`. But from a proof of `True`, there's
nothing to extract.

## Curry-Howard: True ↔ Unit

Under the Curry-Howard correspondence:
- `True : Prop` corresponds to `Unit : Type`
- `True.intro : True` corresponds to `Unit.unit : Unit` (or `()`)

Both are types with exactly one value.
-/

#check Unit         -- Unit : Type
#check Unit.unit    -- Unit.unit : Unit
#check ()           -- () : Unit (notation for Unit.unit)

/-!
## Summary

| Aspect | True |
|--------|------|
| Type | Prop |
| Meaning | Always true |
| Introduction | True.intro (no premises) |
| Elimination | None (no information content) |
| Curry-Howard twin | Unit |
-/

end Alpha.book1lib.chapters.C01_true
