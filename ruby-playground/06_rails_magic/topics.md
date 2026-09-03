## 6. Advanced Metaprogramming

**DSL Creation:** A DSL is a specialized language for a particular domain. Internal DSLs use Ruby's syntax but introduce domain-specific methods. They're implemented using metaprogramming—instance_eval, define_method, etc. DSLs should be human-readable, minimize boilerplate, and be composable.

**Building Rails-like APIs:** Rails-like frameworks use class methods as macros that generate code. They rely on callbacks and hooks for customization. Convention over configuration guides design. Tight integration with the object model through module inclusion creates layered functionality.

**Dynamic Attributes:** Store attributes in a hash and use `method_missing` to make them look like normal attributes. Provides flexibility at the cost of performance. Common for flexible data models but use sparingly due to performance and IDE support limitations.

**Hooks:** Hooks are customization points in a framework. They're callback methods executed at specific points. Users inject custom behavior by registering callbacks. Hooks enable extension without modification, allowing users to customize without changing the framework.

**Callbacks:** Specific hooks that execute at defined lifecycle points. Common patterns include before/after hooks and around hooks. They enable separation of concerns and extensibility by allowing custom behavior at specific moments.

**Framework DSLs:** Combining all metaprogramming techniques creates comprehensive framework DSLs. Design involves defining the domain, identifying key abstractions, designing syntax, implementing mechanisms, providing hooks, and documenting conventions. The result should feel natural and hide complexity.

---
