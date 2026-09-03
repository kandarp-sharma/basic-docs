## 3. Ruby Metaprogramming Basics

**define_method:** This method creates instance methods at runtime. Instead of defining methods with `def` during class definition, you can generate them based on data or conditions. Methods created this way are indistinguishable from those defined with `def`. The block passed to `define_method` becomes the method body and captures its surrounding scope as a closure.

**define_singleton_method:** Like `define_method` but for singleton methods. It creates methods on specific objects or classes. You can add custom behavior to individual objects without creating new classes. It's more elegant than monkey-patching and avoids affecting other objects.

**send:** This method calls methods dynamically by name. Instead of hardcoding the method name, you pass it as a string or symbol. The method name can be computed at runtime. This shows that method calls aren't special syntax in Ruby; they're operations you can manipulate.

**public_send:** Like `send` but only calls public methods. It respects access controls, so it won't accidentally call private methods. Better for use with user-provided method names or untrusted input.

**method_missing:** When a method isn't found in the normal lookup chain, Ruby calls `method_missing` as a fallback. It raises NoMethodError by default but can be overridden to handle any method call. This enables dynamic interfaces and lazy attribute initialization but is a fallback mechanism, not the primary dispatch method.

**respond_to_missing?:** This tells Ruby about methods that are handled by `method_missing`. It makes dynamic methods indistinguishable from real methods for introspection purposes. Without it, `respond_to?` would return false for methods handled by `method_missing`.

**class_eval:** Executes code in the context of a class, as if written in the class body. It has access to class definition context and can modify the class after creation. Useful for programmatically building classes and DSLs that need to modify classes dynamically.

**instance_eval:** Executes code in the context of a specific instance. It has access to instance variables and private methods. It breaks encapsulation by design but enables introspection and block-based configuration patterns.

---
