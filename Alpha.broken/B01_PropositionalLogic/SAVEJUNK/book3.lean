/- 
# Book 3: Propositional Logic - A Deep Embedding
## Implementing a Logic in Lean

This optional book teaches how to implement a logic as a 
programming project. Students build:

- Abstract syntax trees for propositional logic expressions
- Semantic evaluation (interpretation functions)  
- Decision procedures: satisfiability, validity
- Truth table generation
- Model finding

### Note
This is a *programming* project about *implementing* a logic,
not a logic course about *using* a logic. It complements
Books 1-2 by showing the "other side" of formal logic.

### Prerequisites
- Basic Lean programming
- Book 1 recommended but not required
-/

import Alpha.book3lib.library.syntax
import Alpha.book3lib.library.domain
import Alpha.book3lib.library.semantics
import Alpha.book3lib.library.interpretation
import Alpha.book3lib.library.axioms
import Alpha.book3lib.library.identities
import Alpha.book3lib.library.utilities
import Alpha.book3lib.library.model_theory.truthTable
import Alpha.book3lib.library.model_theory.properties
import Alpha.book3lib.library.model_theory.models
import Alpha.book3lib.library.model_theory.counterexamples
