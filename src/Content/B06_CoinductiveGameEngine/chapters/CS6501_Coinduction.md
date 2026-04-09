```lean
import Std
```

# Coinduction and Potentially Infinite Processes

<!-- toc -->

In the *Inductive Types* chapter we studied `Nat`, `List`,
and `Option`. All three are *inductive*: every value is
built by applying a finite number of constructors, and
every recursive function terminates because each recursive
call receives a structurally *smaller* argument. Lean
accepts such functions without the `partial` keyword
because it can verify, mechanically, that the recursion
bottoms out.

## Induction vs. Coinduction

Reactive programs break this contract deliberately. A game
loop does not recurse on a smaller piece of data — it
recurses on the *next world state*, which is just as large
as the current one. There is no base case; the loop runs
until an external condition (user quit, stop predicate)
fires. That condition could, in principle, never fire.

This style of computation is called *coinductive* or
*corecursive*. Where an inductive process is characterized
by how it is *constructed* (bottom-up from a base case),
a coinductive process is characterized by what it *produces
next* (top-down, one observation at a time). The canonical
coinductive structure is an infinite stream: at any moment
you can ask for the *head* (the current value) and the
*tail* (the rest of the stream), but there is no final
element.

A big-bang world is exactly such a stream: at each step
the runtime *observes* the current scene (head), then
steps to the next world (tail). The stream has no
predetermined length; it is potentially infinite.

Because Lean's termination checker cannot prove that a
coinductive loop halts, we mark it `partial`. This is not
a limitation to work around — it is the *honest* signature.
We are telling Lean: "this function may run forever, and
that is by design."

## Mouse Events

We begin with a small enumeration of the mouse events
that the framework recognizes. These correspond to the
standard HtDP mouse event vocabulary.

```lean
namespace HtDPBigBang

universe u v

/-- HtDP-style mouse events. -/
inductive MouseEvent where
  | buttonDown
  | buttonUp
  | drag
  | move
  | enter
  | leave
deriving Repr, BEq, Inhabited
```

## Input Events

Every stimulus the world can receive is wrapped in a
single sum type. The runtime parses user input into one
of these three cases.

`InputEvent` is a perfectly ordinary *inductive* sum type —
the same kind of type as `Option`, `Bool`, or `Expr` from
earlier chapters. Nothing coinductive lives here. The
coinductive part is how the runtime *consumes* an unbounded
sequence of such events over time; the events themselves
are finite, discrete values.

Think of `InputEvent` as the element type of the infinite
stream that the outside world feeds to the game loop.
Each `tick`, `key`, or `mouse` value is one *head* drawn
from that stream.

```lean
/-- External events that can update a world. -/
inductive InputEvent where
  | tick
  | key (k : String)
  | mouse (x y : Nat) (m : MouseEvent)
deriving Repr, BEq, Inhabited
```

## The BigBang Configuration

The `BigBang` structure bundles all the handlers together.
Only `toDraw` is mandatory — everything else defaults to
a no-op. This lets you start with a minimal world and
add behavior incrementally, exactly as HtDP recommends.

The structure is polymorphic in both the `World` type and
the `Scene` type. For our terminal runtime, `Scene` is
`String`, but one could instantiate it with an HTML or
SVG type for a graphical backend.

From the stream perspective, `BigBang` is the *specification*
of a coinductive process without committing to how it runs:

- `toDraw` is the *observation* function — it extracts the
  visible head of the stream (the current scene) from the
  hidden state (the world).
- `onTick` / `onKey` / `onMouse` are the *transition* functions —
  they produce the next hidden state given the current one
  and one element of the incoming event stream.
- `stopWhen` is the *termination guard* — it decides when
  the otherwise-infinite process is allowed to stop.

In a purely coinductive formulation (no `stopWhen`) the
process would be literally infinite. `stopWhen` is our
escape hatch: it converts the coinductive loop into a
`partial` function that *may* terminate. Every handler is
a pure function; no handler touches `IO`. The impurity is
isolated entirely in the runtime that *drives* the loop.

```lean
/--
A terminal-friendly version of HtDP's big-bang configuration.

`toDraw` is mandatory.
All other handlers default to no-ops.
-/
structure BigBang (World : Type u) (Scene : Type v) where
  toDraw : World → Scene
  onTick : World → World := id
  onKey : World → String → World := fun w _ => w
  onMouse : World → Nat → Nat → MouseEvent → World := fun w _ _ _ => w
  stopWhen : World → Bool := fun _ => false
```

## Event Dispatch

`handleEvent` is a pure dispatcher: given a world and
one event, it selects the appropriate handler and returns
the new world. No IO here — the impurity lives entirely
in the runtime loop.

This function is exactly the *step* of the coinductive
transition system. If we were writing a formal stream
processor, `handleEvent bb` would be the *unfold* function:
given the current hidden state and one input observation,
produce the next hidden state. The runtime calls it once
per event, threading the resulting world into the next
iteration.

Notice that `handleEvent` is defined by pattern matching on
`InputEvent` — a finite inductive type. The pattern match
is total and obviously terminating: there are exactly three
cases. The coinductive complexity lives one level up, in
`runTerminal`, which calls `handleEvent` an unbounded number
of times. Separating the finite dispatch from the infinite
loop is a clean architectural boundary between inductive
and coinductive reasoning.

```lean
namespace BigBang

variable {World : Type u} {Scene : Type v}

def handleEvent (bb : BigBang World Scene) (w : World) : InputEvent → World
  | .tick => bb.onTick w
  | .key k => bb.onKey w k
  | .mouse x y m => bb.onMouse w x y m

end BigBang
```

## Terminal Runtime

`runTerminal` is the coinductive heart of the system:

1. **Observe** — render the current world (extract the head)
2. **Guard** — check `stopWhen`; if true, halt
3. **Read** — obtain one event from the environment
4. **Step** — call `handleEvent` to produce the next world
5. **Recur** — loop with the new world as the hidden state

This is precisely the unfold pattern of a stream processor.
Contrast it with a recursive function on `List`:

```
-- Inductive: recurse on a structurally *smaller* list
def sum : List Nat → Nat
  | [] => 0
  | h :: t => h + sum t   -- t is smaller than h :: t ✓
```

```
-- Coinductive: recurse with the *next* world (same size)
partial def runTerminal (bb : BigBang W S) (w : W) : IO Unit := do
  ...
  runTerminal bb w'        -- w' is not smaller than w ✗ for termination
```

Lean's termination checker rejects the second pattern
because `w'` is not structurally smaller than `w`. The
`partial` keyword is our acknowledgement that we are
writing a coinductive process: we assert that the function
is *logically* well-defined (each step is deterministic
and productive) without claiming it terminates.

`Command` is the thin parse layer between raw terminal
input and the `InputEvent` algebra. `help` and `quit` are
meta-commands handled by the runtime itself; only `.step e`
passes through to `handleEvent`.

```lean
inductive Command where
  | step (e : InputEvent)
  | help
  | quit
deriving Repr

def words (s : String) : List String :=
  (s.trimAscii.toString.splitOn " ").filter (fun t => t ≠ "")

def parseMouseEvent? : String → Option MouseEvent
  | "button-down" => some .buttonDown
  | "button-up"   => some .buttonUp
  | "drag"        => some .drag
  | "move"        => some .move
  | "enter"       => some .enter
  | "leave"       => some .leave
  | _             => none

-- ANSI arrow key escape sequences sent by terminals
def parseAnsiArrow (line : String) : Option String :=
  if line == "\x1B[A" then some "up"
  else if line == "\x1B[B" then some "down"
  else if line == "\x1B[C" then some "right"
  else if line == "\x1B[D" then some "left"
  else none

def parseCommand (line : String) : Except String Command :=
  match parseAnsiArrow line with
  | some dir => .ok <| .step (.key dir)
  | none =>
  match words line with
  | [] => .error "Empty command. Type `help`."
  | "help" :: [] => .ok .help
  | "quit" :: [] => .ok .quit
  | "tick" :: [] => .ok <| .step .tick
  | "left" :: [] => .ok <| .step (.key "left")
  | "right" :: [] => .ok <| .step (.key "right")
  | "up" :: [] => .ok <| .step (.key "up")
  | "down" :: [] => .ok <| .step (.key "down")
  | "key" :: k :: [] => .ok <| .step (.key k)
  | "mouse" :: xs :: ys :: kind :: [] =>
      match xs.toNat?, ys.toNat?, parseMouseEvent? kind with
      | some x, some y, some m => .ok <| .step (.mouse x y m)
      | _, _, _ =>
          .error "Usage: mouse <x> <y> <button-down|button-up|drag|move|enter|leave>"
  | _ =>
      .error "Unknown command. Type `help`."

def helpText : String :=
  String.intercalate "\n"
    [ "Commands:"
    , "  tick"
    , "  left"
    , "  right"
    , "  up"
    , "  down"
    , "  key <text>"
    , "  mouse <x> <y> <button-down|button-up|drag|move|enter|leave>"
    , "  help"
    , "  quit"
    ]

partial def runTerminal
    {World : Type u}
    (bb : BigBang World String)
    (w : World) : IO Unit := do
  IO.println ""
  IO.println (bb.toDraw w)
  IO.println ""
  if bb.stopWhen w then
    IO.println "Stopped."
  else
    IO.print "> "
    let stdin ← IO.getStdin
    let line ← stdin.getLine
    let line := (line.dropEndWhile Char.isWhitespace).toString
    match parseCommand line with
    | .error msg =>
        IO.println msg
        runTerminal bb w
    | .ok .help =>
        IO.println helpText
        runTerminal bb w
    | .ok .quit =>
        IO.println "Goodbye."
    | .ok (.step e) =>
        let w' := bb.handleEvent w e
        runTerminal bb w'

end HtDPBigBang
```
