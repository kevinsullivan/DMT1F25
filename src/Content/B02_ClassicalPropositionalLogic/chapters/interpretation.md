# Interpretations

<!-- toc -->

```lean
import Content.B02_ClassicalPropositionalLogic.chapters.semantics

namespace Content.B02_ClassicalPropositionalLogic.chapters.interpretation

open Content.B02_ClassicalPropositionalLogic.chapters.syntax
open Content.B02_ClassicalPropositionalLogic.chapters.semantics
```

An interpretation, *i*, in propositional logic is a function
from variables to Booleans. That is just how we represent
one in Lean: as a value of type Interp, an abbreviation for
the type of total functions from Var to Bool, *Var → Bool*.

Recall that in our specification, a variable expression is
constructed from a variable. All variable expressions built
from the same variable will thus be assigned the same value.

## Defining Interpretations

Suppose for example that we want to evaluate an expression
under an interpretation that assigns the value, *false*, to
every variable, and thus to every variable expression. We
can define such an interpretation in one line.

```lean
def allFalse : Var → Bool := fun _ => false
```

The lambda expression, *fun v => false*, which can also be
written as *λ v => false*, denotes the function that takes
any variable, *v* as an argument and that returns false. We
use an underscore, *_*, in place of the argument name to
indicate that we don't use the argument value in defining
the return value.

In any case, with this interpretation in hand, we can now
evaluate an expression under it. We can use Lean's *reduce*
command to apply *eval* to an expression, *e*, and to *i*,
to answer the question, does *i* satisfy *e*?

```lean
def e : Expr := {⟨0⟩}  -- expression on 0th variable
#reduce eval e allFalse        -- expect false
#reduce ⟦(¬e)⟧ allFalse         -- expect true (our notation)
#reduce ⟦(e ∨ ¬e)⟧ allFalse     -- expect true
#reduce ⟦(e ∧ ¬e)⟧ allFalse     -- expect false
```

We can also easily define the all-true interpretation.

```lean
def allTrue : Interp := λ _ => true   -- _ for don't care
#reduce ⟦e⟧ allTrue            -- expect true
#reduce ⟦(¬e)⟧ allTrue         -- expect false
#reduce ⟦(e ∨ ¬e)⟧ allTrue     -- expect true
#reduce ⟦(e ∧ ¬e)⟧ allTrue     -- expect false
```

Now suppose we want an interpretation for an expression
with two variable sub-expressions. One way to define such
an interpretation function is by case analysis on variable
indices. Here's an interpretation that assigns true to the
0th variable, false to the 1st variable, and true to every
other (irrelevant) variable.

```lean
def tf : Interp :=
fun v =>
  match v with
  | (Var.mk 0) => true    -- using our abstract syntax
  | ⟨1⟩ => false          -- using Lean's notation for mk
  | _ => true             -- default for all other variables

def f : Expr := {⟨1⟩}
#reduce ⟦(e ∧ f)⟧ tf   -- expect false
#reduce ⟦(e ∨ f)⟧ tf   -- expect true
#reduce ⟦(e ⇒ f)⟧ tf   -- expect false
#reduce ⟦(f ⇒ e)⟧ tf   -- expect true
```

## Generating All Interpretations for an Expression

We will soon be at the point where we'll want to
generate all possible interpretation functions for
any given collection of variables. Given that an
expression with *n* distinct variable expressions
has *2^n* interpretations (ignoring valuations for
variables beyond the range of those appearing in
the expression), it'd be a real chore to have to
write exponential numbers of explicit definitions.

To address this problem, we will define functions
that algorithmically construct interpretations from
simple specifications.

For example, we'd like to have a function that takes
any expression, *e*, and returns a list of all *2^n*
of its possible interpretations. This will enable us
to compute *truth tables* for expressions, where each
interpretation corresponds to one row of a truth table
except for the final output value, which is computed
by applying *eval* to *e* and to the interpretation
that the corresponding row of variable values in the
truth table represents.

We build up to this capability through a series of
smaller definitions.

### Overriding Variable-Value Assignments

A useful operation on interpretations is *functional
override*: given an interpretation, a variable, and a
new Boolean value, return a new interpretation that is
identical to the original except that it assigns the
new value to the specified variable. Study this function
with some care. The returned function checks whether the
queried variable matches the overridden one (by index);
if so it returns the new value, otherwise it delegates
to the original interpretation.

```lean
def overrideValue : Interp → Var → Bool → Interp
| i, v, b =>
  fun (v' : Var) =>
    if (v'.index == v.index)
        then b
        else (i v')
```

Here's an example. Remember that *e* is a variable
expression built on the variable *(Var.mk 0)* with
index 0. Here we start with *allFalse* and override
it to assign *true* as the value of this variable.
When we evaluate *e* on the resulting interpretation
we'll see that we get the value, true.
```lean
#reduce ⟦e⟧ allFalse                           -- expect false
def newInterp := overrideValue allFalse ⟨0⟩ true  -- override
#reduce ⟦e⟧ newInterp                          -- expect true
```

### Constructing an Interpretation from a List of Bools

Another useful construction takes a list of Boolean
values and returns an interpretation that maps the
variable with index *k* to the *k*'th element of
the list, with variables beyond the list defaulting
to false. The *getD* function ("get with default")
returns the element at index *k* if it exists, or
the provided default value (here, *false*) otherwise.
```lean
def interpFromBools (l : List Bool) : Interp :=
  fun ⟨k⟩ => l.getD k false
```

Here's an example, where nextInterp assigns true to
the variable with index *0* (and thus as the value it
assigns to *e*), false to the variable with index *1*,
and then false to every variable at any higher index.
```lean
def nextInterp : Interp := interpFromBools [true, false]
#eval ⟦e⟧ nextInterp    -- expect e to evaluate to true
```

### Nth Interpretation for k Variables

A useful observation is that each row of a truth table
(without the final output column) represents an
interpretation, and the Boolean values in each row
correspond to the bits in the binary expansion of the
row index.

For example, if *e* includes two variable expressions,
it will have four rows with indices from *0* to *3*,
with binary expansions 00, 01, 10, 11. The bits in
each of these numerals are exactly the Boolean values
to be assigned to each of the two variables by each of
the respective interpretations.

We can exploit this correspondence to build the
interpretation for any given row directly: for variable
*k* in a row with *numVars* columns, the corresponding
bit is obtained by dividing the row index by *2^(numVars
- 1 - k)* and checking whether the result is odd.

```lean
def interpFromRowNumVars (row : Nat) (numVars : Nat) : Interp :=
  fun ⟨k⟩ =>
    if k < numVars then
      (row / (2 ^ (numVars - 1 - k))) % 2 != 0
    else false
```

### All Interpretations for k Variables

To generate all *2^n* interpretations for *n* variables,
we use a recursive construction. The key insight is that
the set of all interpretations for *n + 1* variables is
obtained by taking each interpretation for *n* variables
and forking it into two: one that binds variable *n* to
false, and one that binds it to true. The base case (zero
variables) is a single interpretation that maps every
variable to false.

This produces interpretations in *ascending* order (from
all-false to all-true), the standard truth-table convention.
Here, *map* applies the forking operation to each existing
interpretation, producing a list of two-element lists, and
*flatten* (List.flatten) flattens this into a single list.

Be careful: the constructed list is exponential in the
number of variables.

```lean
def interpsFromNumVars : Nat → List Interp
  | 0     => [fun _ => false]
  | n + 1 =>
    ((interpsFromNumVars n).map fun i =>
      [overrideValue i ⟨n⟩ false, overrideValue i ⟨n⟩ true]).flatten
```

### Counting the Number of Variables in an Expression

To compute a list of all interpretations for a given expression,
*e*, we just need to know the number of variable expressions in
*e*. That number, in turn, is one more than the highest variable
index value for any variable used in a variable expression in *e*.
As examples, the answer for *P ∧ P* would be *1*; for *⊤* it'd be
*0*, as there are no variable expressions in the expression, *⊤*.

This function definition provides a nice example of case analysis
on the structure of the expression argument, *e*. If it's a literal
expression, there are no variables, so we return *none*. If it's a
variable expression built from the variable (Var) with index i,
the answer is *some i*. For a unary operator expression, *(op e)*,
it's the result for *e*. And for a binary operator expression,
*(op e1 e2)*, it's the maximum of the results for each of *e1*
and *e2*.
```lean
def numVarsFromExpr : Expr → Nat :=
  (fun e =>
    match maxVariableIndex e with
    | none   => 0
    | some n => n + 1) where
maxVariableIndex : Expr → Option Nat
| Expr.lit_expr _ => none
| Expr.var_expr (Var.mk i) => some i
| Expr.un_op_expr _ e => maxVariableIndex e
| Expr.bin_op_expr _ e1 e2 =>
    match maxVariableIndex e1, maxVariableIndex e2 with
    | some a, some b => some (max a b)
    | some a, none   => some a
    | none,   some b => some b
    | none,   none   => none
```

## API: Get List of All Interpretations for Expression

Given an Expr, *e*, return a list of all of its *2^n*
interpretations in *ascending* order (from all-false to
all-true). This function works by computing a list of
all interpretations for *n* variables where *n* is the
number of variables in *e*.
```lean
def interpsFromExpr : Expr → List Interp
| e => interpsFromNumVars (numVarsFromExpr e)
```

### Printable Representations of Interpretations

Since an interpretation is a function (and thus unprintable),
we provide helpers to convert interpretations to printable
lists of Booleans. Given an interpretation and a width *n*,
*bitListFromInterpHelper* returns a list of the Boolean values
assigned to variables with indices *0* through *n-1*.

```lean
def bitListFromInterpHelper (i : Interp) (n : Nat) : List Bool :=
  (List.range n).map (fun k => i ⟨k⟩)

#reduce bitListFromInterpHelper allFalse 3 -- expect [false, false, false]
```

This function takes a list of interpretations and a width
and returns a list of Boolean lists, one for each interpretation.
```lean
def bitListsFromInterpsHelper (interps : List Interp) (n : Nat) : List (List Bool) :=
  interps.map (fun i => bitListFromInterpHelper i n)
```

Lean knows how to print lists of Booleans, and lists
of lists of Booleans, so these functions can be used
to derive printable forms of interpretations and lists
thereof. Remember that an interpretation in our design
binds values to an infinite number of variables, of which
only a finite initial sub-list of variable-to-value
bindings is relevant. We provide the number of *relevant*
variable bindings for which outputs should be generated
as the second argument to this function.

```lean
#reduce bitListsFromInterpsHelper (interpsFromNumVars 3) 3
```

You can ask for bindings for more variables than are relevant,
and in this case, we'll get default values (false) beyond those
that matter. These values are ignored during evaluation and so
are irrelevant; they are an implementation detail in our design.

```lean
#reduce bitListsFromInterpsHelper (interpsFromNumVars 3) 5

-- Example
def anExpr := ({⟨0⟩} ∧ {⟨1⟩} ∨ {⟨2⟩})  -- P ∧ Q ∨ R
#reduce bitListsFromInterpsHelper (interpsFromExpr anExpr) 3
```

### Repr Instance for Interpretations

An interpretation is a function, so Lean can't print it
directly. We provide a Repr instance that displays the
Boolean values assigned to variables 0 through 2 (the
three used in most of our examples).

```lean
instance : Repr Interp where
  reprPrec i _ := repr (bitListFromInterpHelper i 3)

end Content.B02_ClassicalPropositionalLogic.chapters.interpretation
```
