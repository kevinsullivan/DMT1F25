```lean
namespace DMT1.L00_06_false
```

# False

In predicate logic, *False* is a proposition that
is invariably false. In a constructive predicate
logic, such as Lean, if there is a proof of any
proposition, then it's judged to be true (valid).
The condition under which a proposition is false
is that it is known to have no proofs. There are
no values of the type expressing the proposition.

## Introduction

There is no introduction rule for False. There is
no proof of the proposition False. Computationally,
there is no proof term (value, object) of this type,
because the type is expressly defined to have no
values. It's a type with no constructors. It's an
*empty* type. Indeed, it's computational twin under
the Curry-Howard Correspondence is, in Lean, Empty,
the data type with no values.

## Elimination

The question here is how can one use an assumed or
provided proof of False? One can never be provided,
because such a thing doesn't exist. But we can still
define a function that assumes it will be provided
with a proof of this type, and the function code can
be written accordingly, showing that *if* such a value
is ever actually provided, a value of the specificed
return type can be derived and returned.

So here's the secret, the code can never actually
run, because the function can never be applied, as
there's no value of the required type to apply it
to. In this situation, one might as well just bail
out of writing more code. Declare succes. Accept
the function definition knowing it can never really
run. You can have a function of type False → P, that
in turn proves the logical implication, False → P,
for any proposition P whatsoever.

```lean
def myFalseElim (f : False) (P : Prop)
  : P               -- ret. type P, value, a proof
  := False.elim f   -- f justifies bailing out
```

It's important to understand the theorem we just
proved. Give a proof of False, you ca prove any
proposition whatsoever, P. From false, anything
follows. Ex false quodlibet.

```lean
end DMT1.L00_06_false
```
