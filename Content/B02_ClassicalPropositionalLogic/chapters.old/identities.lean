import Content.B02_ClassicalPropositionalLogic.chapters.syntax

namespace Content.B02_ClassicalPropositionalLogic.chapters.identities

def P := {⟨0⟩}
def Q := {⟨1⟩}
def R := {⟨2⟩}

def andIdempotent   := P ↔ (P ∧ P)
def orIdempotent    := P ↔ (P ∨ P)

def andCommutative  := (P ∧ Q) ↔ (Q ∧ P)
def orCommutative   := (P ∨ Q) ↔ (Q ∨ P)

def identityAnd     := (P ∧ ⊤) ↔ P
def identityOr      := (P ∨ ⊥) ↔ P

def annihilateAnd    := (P ∧ ⊥) ↔ ⊥
def annihilateOr     := (P ∨ ⊤) ↔ ⊤

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

end Content.B02_ClassicalPropositionalLogic.chapters.identities
