/- @@@
# More Fundamental Data Types
@@@ -/

namespace CS6501.F26.PropositionalLogic


/- @@@
## Some Programming in Lean

### Using Sum Type Values: Case Analysis

The binary Boolean implies function is not natively implemented
in Lean's Booleal algebra. We know the truth table. Let's see some
ways we can implement it.

#### Term Mode: Match ... With ...
-/

def implies : Bool → Bool → Bool :=
fun b1 =>
  fun b2 =>
    match b1 with
    | true =>
      match b2 with
      | true => true
      | false => false
    | false => true

#eval implies false true



def implies' : Bool → Bool → Bool :=
fun b1 b2 =>
    match b1 with
    | true =>
      match b2 with
      | true => sorry
      | false => sorry
    | false => match b2 with
      | true => sorry
      | false => sorry

def implies'' : Bool → Bool → Bool
| b1, b2 =>
    match b1 with
    | true =>
      match b2 with
      | true => sorry
      | false => sorry
    | false => match b2 with
      | true => sorry
      | false => sorry

#check true
#check false

def implies3 : Bool → Bool→ Bool
| false, false => true
| false, true => true
| true,  false => false
| true,  true => true

def implies2 : Bool → Bool→ Bool
| true, false => false
| _, _ => true

-- -- in my namespace
-- inductive Bool where
-- | true
-- | false

-- inductive Pet where
-- | cat
-- | dog
-- | bird


-- def Says : Pet → String
-- | .cat => "Meow"
-- | .dog => "Woof"
-- | .bird => "Tweet"

-- open Pet

-- def Says' : Pet → String
-- | cat => "Meow"
-- | dog => "Woof"
-- | bird => "Tweet"

-- def Says'' : Pet → String :=
-- fun p =>
--   match p with
--   | Pet.cat => "Meow"
--   | Pet.dog => "Woof"
--   | Pet.bird => "Tweet"

-- #eval Says Pet.cat


/- @@@
#### Tactic Mode: Cases

Tactics in Lean are programs someone has written
to operate on your proof state in useful ways. They
can fail in which case they leave things unchanged.
There's a whole bunch of them. Let's jump right in
to see the same function definition in tactic mode.
@@@ -/

def implies'''' :  Bool → Bool → Bool := by
  intro b1
  intro b2
  cases b1
  cases b2
  exact true
  exact true
  cases b2
  exact false
  exact true

#eval implies'''' false false


-- Bind argument names early and globally
def implies''''' (b1 b2 : Bool) : Bool := by
cases b1
cases b2
exact true
exact true
cases b2
exact false
exact true


/- @@@
The *cases h : b* variant does the same case
analysis but not inserts explicit proof terms
in your context reflecting what branch of the
case analyses you're currently on.
@@@ -/
def implies'''''' (b1 b2 : Bool) : Bool := by
cases h1 : b1
cases h2 : b2
exact true
exact true
cases h2 : b2
exact false
exact true

/- @@@
#### Bottom Line

To construct the value of any sum type, use on
of its constructors. To use a value of any sum
type (other than treating it as a black box) use
case analysis, with one case per constructor.

### Product Types

As a reminder, a product type is a type with one
constructor having any number of fields, but usually
two or more. Most of the *classes* you've define in
CS1 define product types. There is one set of member
variables and every object of a given type has just
that same set of data fields.

Recall that inductive type definitions are generally
introduced with the *inductive* keywork, but product
types can uniquely be introduced using the *structure*
keyword. In return you get the following:

- *mk* default constructor name with ⟨ _, ... ⟩ notation
- field access using field name as projection function

@@@ -/

structure Pet where (species : String) (name : String) (license : Nat)

#check Pet.mk


-- Introduction rule
def myCat : Pet := Pet.mk "Siamese" "MissKitty" 1234

-- Structure notation
def myDog : Pet := ⟨ "Wolf", "Arnie", 0 ⟩

-- Curly brace notation
def myDog' : Pet :=
{
  name := "Arnie",
  license := 0,
  species := "Wolf"
}

-- Elimination: getName

def getName : Pet → String
| Pet.mk _ n _ => n

#eval getName myCat


-- Use value of product type by destructing it
-- Here is an example where we do that explicitly
def petLicense : Pet → Nat
| ⟨_, _, l⟩  => l

#eval
  let p := Pet.mk "Cat" "Moww" 12345
  petLicense p


-- Use of field name as projection function
#eval
  let p := Pet.mk "Cat" "Moww" 12345
  Pet.license p

#eval
  let p := Pet.mk "Cat" "Moww" 12345
  p.license

/- @@@
## Prod and Sum types in Lean

Let's now look at Lean's Prod and Sum types in
more detail.
@@@ -/

#check Prod

/-
structure Prod (α : Type u) (β : Type v) where
  mk :: (fst : α) (snd : β)
-/



#check Sum

/-

inductive Sum (α : Type u) (β : Type v) where
  | inl (val : α) : Sum α β
  | inr (val : β) : Sum α β
-/

def myString : Sum String Bool := Sum.inl "Hi"
def myBool :   Sum String Bool := Sum.inr true

def stringOrBool : Sum String Bool → String
| Sum.inl _ => "String"
| Sum.inr _ => "Bool"

def stringAndBool : Prod String Bool := ⟨ "Hi", true ⟩

def useStringAndBool :  Prod String Bool → Bool
| ⟨ s, b ⟩ => b

#eval useStringAndBool stringAndBool


end CS6501.F26.PropositionalLogic
