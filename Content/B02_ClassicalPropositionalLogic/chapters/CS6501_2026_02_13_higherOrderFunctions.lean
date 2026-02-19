
import Content.B02_ClassicalPropositionalLogic.chapters.classicalPropLogic.syntax
import Content.B02_ClassicalPropositionalLogic.chapters.classicalPropLogic.semantics
import Content.B02_ClassicalPropositionalLogic.chapters.classicalPropLogic.interpretation
import Content.B02_ClassicalPropositionalLogic.chapters.CS6501_2026_02_09

open Content.B02_ClassicalPropositionalLogic.chapters.classicalPropLogic.interpretation
open Content.B02_ClassicalPropositionalLogic.chapters.classicalPropLogic.semantics

namespace Content.B02_ClassicalPropositionalLogic.higherOrderFunctions
-- Example
def anExpr := ({⟨0⟩} ∧ {⟨1⟩} ∨ {⟨2⟩})  -- P ∧ Q ∨ R

-- toString is Programmed to write P, Q, R as names for first three Vars
#eval toString anExpr
#eval toString ({⟨0⟩} ∧ {⟨1⟩} ∨ {⟨2⟩} ⇒ {⟨3⟩})

#reduce bitListsFromInterpsHelper (interpsFromExpr anExpr) 3


#check List.map

def e' := {⟨0⟩} ∧ {⟨1⟩}
def li : List Interp := interpsFromExpr e'
#reduce li
#eval li.length
#eval eval e' li[0]
#eval eval e' li[1]
#eval eval e' li[2]
#eval eval e' li[3]


def outputs := List.map (fun i => eval e' i) li
#reduce outputs


def myReduceAnd : List Bool → Bool
| [] => true
| h::t => h && (myReduceAnd t)

def myReduceOr : List Bool → Bool
| [] => false
| h::t => h || (myReduceOr t)

def myReduce1 {α : Type} : (op : α → α → α) → (id : α) → List α → α
| _, id, [] => id
| op, id, h::t => op h (myReduce1 op id t)


#eval myReduceAnd outputs
#eval myReduceOr outputs


def isEven n := n % 2 == 0
def reduceStringsToBool : List String → Bool
| [] => true
| h::t => (isEven h.length) && (reduceStringsToBool t)

#eval reduceStringsToBool ["","!!"]

end Content.B02_ClassicalPropositionalLogic.higherOrderFunctions
