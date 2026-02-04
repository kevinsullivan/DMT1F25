import Content.book3lib.library.model_theory.models


open Content.book3lib.library.syntax
open Content.book3lib.library.semantics
open Content.book3lib.library.model_theory.models

namespace Content.book3lib.library.counterexamples

/- @@@
# Counterexamples

We return all counterexamples, or one if there was one, for
any given expression. These operations find models of the negation
of the given expression, which amount to counterexamples for it.
@@@ -/

def findCounterexamples (e : Expr) : List Interp := findModels ¬e

def findCounterexample (e : Expr) : Option Interp := findModel ¬e

end Content.book3lib.library.counterexamples
