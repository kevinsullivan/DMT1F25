```lean
import DMT1.Library.propLogic.model_theory.models
import DMT1.Library.propLogic.semantics

namespace DMT1.Library.propLogic.model_theory.models
open propLogic.syntax
open semantics
```


# Counterexamples

We return all counterexamples, or one if there was one, for
any given expression. These operations find models of the negation
of the given expression, which amount to counterexamples for it.

```lean
def findCounterexamples (e : Expr) : List Interp := findModels ¬e

def findCounterexample (e : Expr) : Option Interp := findModel ¬e

end DMT1.Library.propLogic.model_theory.models
```
