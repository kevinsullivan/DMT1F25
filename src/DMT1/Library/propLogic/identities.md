```lean
import «DMT1».Library.propLogic.syntax

namespace DMT1.Library.propLogic.identities

open propLogic.syntax
```

# Identities

```lean
-- variable expressions
def P := Expr.var_expr (Var.mk 0)
def Q := {(Var.mk 1)}
def R := {⟨2⟩}

-- some important equivalences ("identities")

def andIdempotent   := P ↔ (P ∧ ¬ P)
def orIdempotent    := P ↔ (P ∨ P)

def andCommutative  := (P ∧ Q) ↔ (Q ∧ P)
def orCommutative   := (P ∨ Q) ↔ (Q ∨ P)

def identityAnd     := (P ∧ ⊤) ↔ P
def identityOr      := (P ∨ ⊥) ↔ P

def annhilateAnd    := (P ∧ ⊥) ↔ ⊥
def annhilateOr     := (P ∨ ⊤) ↔ ⊤

def orAssociative   := ((P ∨ Q) ∨ R) ↔ (P ∨ (Q ∨ R))
def andAssociative  := ((P ∧ Q) ∧ R) ↔ (P ∧ (Q ∧ R))

def distribAndOr    := (P ∧ (Q ∨ R)) ↔ ((P ∧ Q) ∨ (P ∧ R))
def distribOrAnd    := (P ∨ (Q ∧ R)) ↔ ((P ∨ Q) ∧ (P ∨ R))

def distribNotAnd   := ¬(P ∧ Q) ↔ (¬P ∨ ¬Q)  -- DeMorgan's law
def distribNotOr    := ¬(P ∨ Q) ↔ (¬P ∧ ¬Q)  -- DeMorgan's law

def equivalence     := (P ↔ Q) ↔ ((P ⇒ Q) ∧ (Q ⇒ P))
def implication     := (P ⇒ Q) ↔ (¬P ∨ Q)
def exportation     := ((P ∧ Q) ⇒ R) ↔ (P ⇒ Q ⇒ R)
def absurdity       := (P ⇒ Q) ∧ (P ⇒ ¬Q) ⇒ ¬P
```

We'll soon see that almost all of these expressions,
when given standard meetings, is always true: for any
assignment of Boolean values as the specified meanings
of the variables: that is, for any *interpretation*.

Indeed, we'll define an executable formal specification
of this checker, capable of checking *any* expression to
determine if it has the property of being valid or not.

Here's what it looks like to run the validity checker.
But before going there, we need a simple semantics for
an expression given an interpretation.

```lean
#eval! is_valid andIdempotent
#eval! is_valid orIdempotent

#eval! is_valid andCommutative
#eval! is_valid orCommutative

#eval! is_valid identityAnd
#eval! is_valid identityOr

#eval! is_valid annhilateAnd
#eval! is_valid annhilateOr

#eval! is_valid orAssociative
#eval! is_valid andAssociative

#eval! is_valid distribAndOr
#eval! is_valid distribOrAnd

#eval! is_valid distribNotAnd
#eval! is_valid distribNotOr

#eval! is_valid equivalence
#eval! is_valid implication
#eval! is_valid exportation
#eval! is_valid absurdity
```
Fun exercise: Figure out which one's aren't valid and
give a proof of invalidity for each, in the form of an
single interpretation under which the given expression
is false.

```lean
end DMT1.Library.propLogic.identities
```
