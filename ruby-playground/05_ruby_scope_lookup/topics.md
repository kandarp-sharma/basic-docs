## 5. Ruby Internals & Method Lookup

**VM Method Lookup:** When you call a method, the VM follows a specific algorithm. It checks the object's singleton class first, then its class, then superclasses, then included modules up through BasicObject. If not found, it calls `method_missing`. The VM caches method lookups for performance.

**Eigenclass Details:** Every object has an eigenclass (singleton class) created lazily when the first singleton method is defined. Each object has its own unique eigenclass. For classes, the eigenclass is where class methods live. The eigenclass inherits from the object's regular class.

**Method Tables:** Classes and modules store methods in internal method tables. Method lookup is essentially searching these tables sequentially through the ancestor chain. When you query `instance_methods`, Ruby is reading these method tables. The tables store the method name and compiled code.

**Constants Lookup:** Constants are looked up differently than methods. Lookup starts from lexical scope (where code is written), then outer scopes, then the inheritance hierarchy. Use `::` for explicit constant lookup. Constants are resolved more statically than methods.

**Lexical Scope:** Lexical scope is determined by where code is written, not where it's called from. Local variables are lexically scoped—they exist only in their definition block. Closures capture lexical scope. Constants follow lexical scoping rules.

**Ruby Execution Model:** Ruby code is parsed into an AST, compiled to YARV bytecode, then executed by the VM. Modern Rubies may include JIT compilation. The VM handles method dispatch, memory management, and control flow. Ruby is compiled, not purely interpreted, though you can't see the compilation.

---
