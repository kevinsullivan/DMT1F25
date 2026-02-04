```lean
import DMT1.Library.propLogic.model_theory.properties

namespace DMT1.Library.propLogic.model_theory.models
open propLogic.syntax
open semantics
open interpretation
```

# Models

A model is an interpretation that makes a proposition true.
A "SAT solver" (like is_sat) returns true if  there's at least
one such interpretation. A function that actually returns such
an interpretation (not just a Boolean value) is called a model
finder. A related problem is to find *all* models of a given
proposition. How would you do that? You can use the function,
findModels. It returns a list of all models of a given expression
(but will run out of space or time quickly as the problem size
grows).

```lean
def findModels (e : Expr) : List Interp :=
  List.filter
    (fun i => eval e i = true) -- given i, true iff i is model of e
    (listInterpsFromExpr e)
```

Finds all models, if any, and returns either none, if there
wasn't one, or some m, where m is first in the returned list
of models.
```lean
def findModel :  Expr → Option Interp
| e =>
  let ms := findModels e
  match ms with
  | [] => none
  | h::_ => h

end DMT1.Library.propLogic.model_theory.models
```
