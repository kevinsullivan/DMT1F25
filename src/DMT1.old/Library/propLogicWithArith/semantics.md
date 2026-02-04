```lean
import «DMT1».Library.propLogicWithArith.syntax
import «DMT1».Library.propLogicWithArith.domain
import «DMT1».Library.natArithmetic.semantics

/-!
# Semantics of Propositional Logic with Arithmetic Relations
-/

namespace DMT1.propLogicwithArith.semantics

open DMT1.propLogicWithArith.syntax


def evalUnOp : UnOp → (Bool → Bool)
| (UnOp.not) => not


def evalBinOp : BinOp → (Bool → Bool → Bool)
| BinOp.and => and    -- Bool and operator, &&, from Lean
| BinOp.or => or      -- Bool or operator, ||, from Lean
| BinOp.imp => DMT1.propLogicwithArith.domain.imp
| BinOp.iff => domain.iff --shortened qualifier works


abbrev Interp := Var → Bool -- VarInterp would be better name


abbrev ArithInterp := natArithmetic.syntax.Var → Nat


-- Semantic evaluation of PLA Expressions under *two* variable interpretations
def evalPLAExpr : PLAExpr → Interp → ArithInterp → Bool
| (PLAExpr.lit_expr b),             _, _ => b
| (PLAExpr.var_expr v),           i, _ => i v
| (PLAExpr.un_op_expr op e),      i, a => (evalUnOp op) (evalPLAExpr e i a)
| (PLAExpr.bin_op_expr op e1 e2), i, a => (evalBinOp op) (evalPLAExpr e1 i a) (evalPLAExpr e2 i a)
| (PLAExpr.rel_op_expr re),       _, a => (natArithmetic.semantics.evalRelExpr re a)

end DMT1.propLogicwithArith.semantics
```
