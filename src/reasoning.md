# Reasoning and Computation

## Important Distinct Forms of Reasoning

- Abductive
- Inductive
- Deductive

### Abductive Reasoning

Abductive reasoning is a form of logical inference where you start with an observation or set of observations, in practice often by noticing discrepancies that others might miss, and then in your mind you search for a most plausible explanation. Abductive reasoning is often summarized as “inference to the best explanation.” Abduction hypothesizes an explanation that could make the observed facts true. 

Example: If you walk outside and the ground is wet, you might abductively reason that it has rained. Other explanations are possible (sprinklers, someone washing a car), but rain may seem most plausible.

Abduction is central in everyday reasoning: medical diagnosis, scientific discovery, debugging. Take debugging. You are trying to determine why your program is malfunctioning. You slow it down using a debugger to study its internal states. You notice that the bug always seems to act up when a particular function is called. You hypothesize (by abduction) that the bug is actually in that function. You then go on to test your hypothesis. If a first hypothesis turns out to be wrong, you try again. If it was right, now you know what's wrong and so can proceed to fix it.

### Inductive Reasoning

Inductive reasoning is about generalizing from particular cases to broader patterns or rules. Inductive reasoning underlies much of science, statistics, and machine learning. Inductive reasoning begins with (often systematic) observation. Then derives chooses a class of *models* (such as linear, straight line models), and finds a model of that kind that best fits the data. The idea is that such a model can have predictive power, in the sense that it can make good predictions even for cases that have not yet been seen in the *training data*. Inductive reasoning can be intuitive, e.g., it doesn't take too many times touching a hot pan to learn a model in your mind that predicts is a bad idea to ever do it again.

As for model selection, remember Johannes Kepler. Based on incredibly careful, comprehensive, detailed  observation (data) by Tycho Brahe, Kepler *inductively reasoned* to the conclusion that right model for the orbits of planents was eliptical not circular. Finding beautful models that match data beautifully is an idea at the very heart of science, and human reasoning, whether intuitive or rigorously logical.

### Deductive Reasoning

Deductive reasoning is a process of deriving of necessary conclusions from given logical assumptions using specified rules of inference. For example, suppose we know that a liqud labelled *A* is poison, and we know that a different liquid labelled *B* is also poison. Suppose furthermore that we know that poor Billy drank *A* or drank *B*. Do your own reasoning.

We've already seen that to construct a proof of a proposition, P ∧ Q, one must have a proof (call it p) of the proposition, P, and one must have a proof (call it q) of the proposition Q. One can then have a proof of *P ∧ Q* by applying the proof-building function, *And.intro*, to the proof, *p* and *q*, as in the term, *And.intro p q*.  This term is, in this logic, the one and only proof of *P ∧ Q*. 

But in our next example, we have *Or*, not an *And*. We know only that *poor Billy drank A* *OR* *poor Billy drank B*. Here comes a new inference rule for *Or*: if you know *A ∨ B* is true and you also know that the same result occurs in either case then you know that that result occurs. Sadly, poor Billy is no longer.

We can even write this idea formally, like this:

```lean
  ∀ (P Q R : Prop),     -- if you have *any* (∀) three propositions, P, Q, and R
    (porq : P ∨ Q) ∧    -- and if you have a proof that (P or Q) is true  
    (pimr : P → R) ∧    -- and if you have a proof that if P is true so is R
    (qimr : Q → R ) →   -- and if you have a proof that if Q is true so is R
    R                   -- then by the *or elimination* rule, you have a proof of *R*  
```

Check your own understanding: How do P, Q, and R correspond to "Billy drank A,"
"Billy drank B", and "Billy died?" in the preceding generalized expression?

## Constructive Logic

For the rest of this class, we shall be concerned with *deductive* reasoning as the crucial form of reasoning required to construct or check proofs of propositions expressed in mathematical languages. We will use the constructive logic of the Lean 4 programming language and proof assistant as both the most useful logic for computer scientists to learn today and as an incredible tool for learning about logic and mathematics more generally.

Yet, whether or not you're using a tool such as Lean, or even a constructive logic such as that of Lean, the fact is that the inference rules of deductive logic correspond directly to *programs*. It makes all the sense in the world for computer science students, out of all students, to learn logic, and then the mathematics built on it, in this light.

Consider the *formal* (in Lean 4) expression of the inference rule that allows you to conclude that Billy died, having drank A or having drank B. If you want to conclude that Billy died, that's not yet enough. You also need to know that drinking A is deadly (R) and that drinking B is deadly. Knowing that a bad thing happens *in either case, and that one of the cases happen* is the intuition being this new inference rule: the rule of *or elimination*. This is a rule that *uses* a proof of *P or Q* along with some additional knowledge to derive a proof of *R*. This deductive reasoning inference rule isn't just a logically correct way to think; it's a darned program.
