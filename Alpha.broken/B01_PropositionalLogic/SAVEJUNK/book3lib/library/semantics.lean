/- @@@
# Semantics
@@@ -/

import Content.book3lib.library.syntax
import Content.book3lib.library.domain

open Content.book3lib.library.syntax
open Content.book3lib.library.domain

namespace Content.book3lib.library.semantics


/- @@@
Give each syntactic unary operator a meaning
in the semantic domain of PL: Boolean algebra.
@@@ -/
def evalUnOp : UnOp → (Bool → Bool)
| (UnOp.not) => Bool.not

/- @@@
Give each syntactic unary operator a meaning
in the semantic domain of PL: Boolean algebra.
@@@ -/
def evalBinOp : BinOp → (Bool → Bool → Bool)
| BinOp.and => Bool.and
| BinOp.or => Bool.or
| BinOp.imp => Content.book3lib.library.domain.imp
| BinOp.iff => Content.book3lib.library.domain.iff

open Expr

/- @@@
Give a name to the type of function that will
represent an interpretation.
@@@ -/

def Interp := (Var → Bool)

/- @@@
Semantic evaluation of an expression e under and interpretation i
@@@ -/

def eval : Expr → Interp → Bool
| lit_expr b,             _ => b
| (var_expr v),           i => i v
| (un_op_expr op e),      i => (evalUnOp op) (eval e i)
| (bin_op_expr op e1 e2), i => (evalBinOp op) (eval e1 i) (eval e2 i)

/- @@@
The standard notation for (eval e i) is
@@@ -/

notation "⟦" e "⟧" i => (eval e i)

end Content.book3lib.library.semantics
