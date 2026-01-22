import Alpha.book3lib.library.interpretation

open Alpha.book3lib.library.syntax
open Alpha.book3lib.library.semantics
open Alpha.book3lib.library.interpretation

namespace Alpha.book3lib.library.model_theory
namespace truthTable

/- @@@
#### Truth Table Output Column

Given expression, return truth table outputs by ascending row
index, and where the all false row thus appears at the "top" of
the "table", and each subsequent row is "incremented" in binary
arithmetic up to the row at index 2^n-1, where n is the number
of variables.
@@@ -/

def truthTableOutputs : Expr → List Bool
| e =>  evalBoolExpr_interps (listInterpsFromExpr e) e where
evalBoolExpr_interps : List (Interp) → Expr → List Bool
| [], _ => []
| h::t, e => [eval e h] ++ evalBoolExpr_interps t e

end Alpha.book3lib.library.model_theory.truthTable
