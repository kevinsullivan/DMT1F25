### Satisfiability

We built a satisfiability checker. The procedure it implements
*decides* whether any propositional logic expression, e, has at
least one interpretation, i, such that (i e) is true. It works
by generating all 2^n intepretation for any set of n propositional
variables, evaluating the expression under each interpretation,
then returning true if and only if any of the results are true.

With the same underlying machinery we can easily implement what
we will *decision procedures* that similarly answer two similar
questions: does a given expression, e, have the *property* of
being *unsatisfiable?* And does "e" have the property of being
*valid*.

```lean
import DMT1.Library.propLogic.model_theory.truthTable
namespace DMT1.Library.propLogic.model_theory
open propLogic.syntax
open truthTable
open semantics
open utilities
```

## Decision Procedures for Properties of PL Expressions

```lean
/-!
INTERFACE
-/
```



Satisfiability means there's *some* interpretation for which e is true
```lean
def is_sat :    Expr → Bool :=
  λ e : Expr => reduce_or (truthTableOutputs e)
```

Validity means that a proposition is true under all interpretations
```lean
def is_valid :  Expr → Bool :=
  λ e : Expr => reduce_and (truthTableOutputs e)

def is_unsat : Expr → Bool :=
  λ e : Expr => not (is_sat e)

def is_model : (Var → Bool) → Expr → Bool :=
  fun i e => eval e i

end DMT1.Library.propLogic.model_theory
```
