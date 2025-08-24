```lean
import «DMT1».Lectures.L02_propLogic.formal.syntax

namespace DMT1.lecture.propLogic

def P := {⟨0⟩}
def Q := {⟨1⟩}
def R := {⟨2⟩}

def andIdempotent   := P ↔ (P ∧ P)
def orIdempotent    := P ↔ (P ∨ P)

def andCommutative  := (P ∧ Q) ↔ (Q ∧ P)
def orCommutative   := (P ∨ Q) ↔ (Q ∨ P)

def identityAnd     := (P ∧ ⊤) ↔ P
def identityOr      := (P ∨ ⊥) ↔ P

def annhilateAnd    := (P ∧ ⊥) ↔ ⊥
def annhilateOr     := (P ∨ ⊤) ↔ ⊤

def orAssociative   := ((P ∨ Q) ∨ R) ↔ (P ∨ (Q ∨ R))
def andAssociative  := ((P ∧ Q) ∧ R) ↔ (P ∧ (Q ∧ R))

def equivalence     := (P ↔ Q) ↔ ((P ⇒ Q) ∧ (Q ⇒ P))
def implication     := (P ⇒ Q) ↔ (¬P ∨ Q)
def exportation     := ((P ∧ Q) ⇒ R) ↔ (P ⇒ Q ⇒ R)
def absurdity       := (P ⇒ Q) ∧ (P ⇒ ¬Q) ⇒ ¬P

-- DeMorgan's laws
def distribAndOr    := (P ∧ (Q ∨ R)) ↔ ((P ∧ Q) ∨ (P ∧ R))
def distribOrAnd    := (P ∨ (Q ∧ R)) ↔ ((P ∨ Q) ∧ (P ∨ R))

def distribNotAnd   := ¬(P ∧ Q) ↔ (¬P ∨ ¬ Q)
def distribNotOr    := ¬(P ∨ Q) ↔ (¬P ∧ ¬ Q)

end DMT1.lecture.propLogic
```
