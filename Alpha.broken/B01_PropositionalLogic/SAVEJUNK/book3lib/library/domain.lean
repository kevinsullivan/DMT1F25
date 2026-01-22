namespace Alpha.book3lib.library.domain
/- @@@
# Boolean Algebra

Lean already provides most of what we need. Here we
define the few elements we need that are missing from
the standard Lean libraries

## Boolean values

They are true and false.

- true
- false

## Boolean operators

- && (and)
- || (or)
- ! (not)

## We also need (but Lean doesn't define)

- ⇒ (implies)
- ↔ (equivalent to)
@@@ -/

-- Boolean Operation: Implication
def imp : Bool → Bool → Bool
| true, true => true
| true, false => false
| false, true => true
| false, false => true

-- Boolean Operation: Equivalence
def iff : Bool → Bool → Bool
| true, true => true
| false, false => true
| _, _ => false

end Alpha.book3lib.library.domain
