# Semantic Domain: Boolean Algebra

<!-- toc -->

```lean
namespace DMT.theoryExtensions.domain

def imp : Bool → Bool → Bool
| true, true => true
| true, false => false
| false, true => true
| false, false => true

def iff : Bool → Bool → Bool
| true, true => true
| false, false => true
| _, _ => false

end DMT.theoryExtensions.domain
```
