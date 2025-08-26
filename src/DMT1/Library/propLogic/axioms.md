# Examples of Expressions

It'll suffice for our purposes to have three variable
expressions. We'll call them P, Q, and R. The following
definitions provide them, built on the variables indexed
by 0, 1, and 2, resp. See our concrete syntax definitions.


Mote that the first example is written entirely using
abstract syntax, with the next two showing uses of our
concrete notations. Note: (Var.mk 1) uses parentheses,
while ⟨2⟩ uses special angle brackets. Look closely.
Lean provides this notation as a shorthand for applying
the "mk" constructor of any structure type, here Var.mk.

```lean
import DMT1.Library.propLogic.syntax
namespace DMT1.Library.propLogic.syntax

open Expr

def P : Expr := var_expr (Var.mk 0)
def Q : Expr := {Var.mk 1}
def R : Expr := {⟨2⟩}   -- angle brackets
```


Now that we have a few elementary expressions
(we can call them propositions) we present a set
of propositions that turn out to be important. For
now, they're just examples of syntactically correct
expressions in the syntax of our little language.

```lean
def and_intro :=        R ⇒ Q ⇒ R ∧ Q
def and_elim_left :=    R ∧ Q ⇒ R
def and_elim_right :=   R ∧ Q ⇒ Q

def or_intro_left :=    R ⇒ R ∨ Q
def or_intro_right :=   Q ⇒ R ∨ Q
def or_elim :=          Q ∨ R ⇒ (Q ⇒ P) ⇒ (R ⇒ P) ⇒ P

def not_intro :=        (R ⇒ ⊥) ⇒ ¬R
def not_elim :=         ¬¬R ⇒ R

def imp_intro :=        R ⇒ P ⇒ (R ⇒ P)
def imp_elim :=         (R ⇒ P) ⇒ R ⇒ P

def equiv_intro :=      (R ⇒ P) ⇒ (P ⇒ R) ⇒ (R ↔ P)
def equiv_elim_left :=  (R ↔ P) ⇒ (R ⇒ P)
def equiv_elim_right := (R ↔ P) ⇒ (P ⇒ R)

def true_intro := ⊤
def false_elim := ⊥ ⇒ P
```

As an aside, we can apply our validity checker
(our *is_valid* function) to each proposition
to confirm that each and every one of them is
valid. We're not there yet but will be soon. In
the meantime, here's what it will look like to
apply the checker we'll specify.

```lean
#eval! is_valid  and_intro
#eval! is_valid  and_elim_left
#eval! is_valid  and_elim_right

#eval! is_valid  or_intro_left
#eval! is_valid  or_intro_right
#eval! is_valid  or_elim

#eval! is_valid  not_intro
#eval! is_valid  not_elim

#eval! is_valid  imp_intro
#eval! is_valid  imp_elim

#eval! is_valid  equiv_intro
#eval! is_valid  equiv_elim_left
#eval! is_valid  equiv_elim_right

#eval! is_valid  true_intro
#eval! is_valid false_elim
```

```lean
end DMT1.Library.propLogic.syntax
```
