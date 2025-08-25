# Semantics

```lean
import DMT1.Library.propLogic.syntax
import DMT1.Library.propLogic.domain

namespace DMT1.Library.propLogic.semantics
open propLogic.syntax
```

Give each syntactic unary operator a meaning
in the semantic domain of PL: Boolean algebra.
```lean
def evalUnOp : UnOp → (Bool → Bool)
| (UnOp.not) => Bool.not
```

Give each syntactic unary operator a meaning
in the semantic domain of PL: Boolean algebra.
```lean
def evalBinOp : BinOp → (Bool → Bool → Bool)
| BinOp.and => Bool.and
| BinOp.or => Bool.or
| BinOp.imp => domain.imp
| BinOp.iff => domain.iff

open Expr
```

Give a name to the type of function that will
represent an interpretation.

```lean
def Interp := (Var → Bool)
```

Semantic evaluation of an expression e under and interpretation i

```lean
def eval : Expr → Interp → Bool
| lit_expr b,             _ => b
| (var_expr v),           i => i v
| (un_op_expr op e),      i => (evalUnOp op) (eval e i)
| (bin_op_expr op e1 e2), i => (evalBinOp op) (eval e1 i) (eval e2 i)
```

The standard notation for (eval e i) is

```lean
notation "⟦" e "⟧" i => (eval e i)

end DMT1.Library.propLogic.semantics
```
