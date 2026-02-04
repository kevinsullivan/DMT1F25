```lean
import «DMT1».Library.natArithmetic.syntax
import «DMT1».Library.natArithmetic.domain

namespace DMT1.natArithmetic.semantics

-- given syntactic operator terms, return corresponding Nat- and Bool-valued functions
open DMT1.natArithmetic.syntax

def evalUnOp : UnOp → (Nat → Nat)
| UnOp.inc    => Nat.succ
| UnOp.dec    => Nat.pred
| UnOp.doub   => (fun n => n * 2)
| UnOp.halve  => (fun n => n / 2)
| UnOp.fac    => domain.fac

def evalBinOp : BinOp → (Nat → Nat → Nat)
| BinOp.add => domain.add
| BinOp.sub => domain.sub
| BinOp.mul => domain.mul

def evalRelOp : RelOp → (Nat → Nat → Bool)
| RelOp.eq => domain.eq    -- eq is from from natArithmetic.domain
| RelOp.le => domain.le    -- etc.
| RelOp.lt => domain.lt
| RelOp.ge => domain.ge
| RelOp.gt => domain.gt

-- a function for evaluating "literal n" expressions -- it's just n
def evalLit (n : Nat) : Nat := n

-- The *type* of an interpretation
def Interp := Var → Nat

-- A function for evaluating variable values under given interpretations
def evalVar : Var → Interp → Nat  -- evalVar is a function
| v, i => i v   -- apply interpretation i to variable v to get value

-- Semantic evaluation of arithmetic expression, yielding its Nat value
def eval : Expr → Interp → Nat
| Expr.lit n,          _   => (evalLit n)
| Expr.var v,          i   => (evalVar v i)
| Expr.unOp op e,      i   => (evalUnOp op) (eval e i)
| Expr.binOp op e1 e2, i   => (evalBinOp op) (eval e1 i) (eval e2 i)

-- Semantic evaluation of a relational expression, with a Boolean indication
def evalRelExpr : RelExpr → Interp → Bool
| RelExpr.mk op e1 e2, i =>  (evalRelOp op) (eval e1 i) (eval e2 i)


end DMT1.natArithmetic.semantics
```
