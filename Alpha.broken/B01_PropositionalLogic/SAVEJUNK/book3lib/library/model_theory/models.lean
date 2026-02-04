import Content.book3lib.library.model_theory.properties

namespace Content.book3lib.library
open Content.book3lib.library.syntax
open semantics
open interpretation
namespace model_theory.models

/- @@@
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
@@@ -/

def findModels (e : Expr) : List Interp :=
  List.filter
    (fun i => eval e i = true) -- given i, true iff i is model of e
    (listInterpsFromExpr e)

/- @@@
Finds all models, if any, and returns either none, if there
wasn't one, or some m, where m is first in the returned list
of models.
@@@ -/
def findModel :  Expr → Option Interp
| e =>
  let ms := findModels e
  match ms with
  | [] => none
  | h::_ => h

end Content.book3lib.library.model_theory.models
