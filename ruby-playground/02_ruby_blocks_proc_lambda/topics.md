## 2. Blocks, Procs & Lambdas

**Blocks:** Blocks are not objects; they're syntactic constructs—chunks of code passed to methods. They exist at parse time, not as runtime objects. Only one block can be passed per method call. They're identified by position, not by name. Blocks are optimized for passing code to methods without the overhead of creating Proc objects.

**Yield:** Yield is a keyword that executes the block passed to a method. It's not a method call; it's special syntax for transferring execution to the block. If no block is provided and yield is called, an error occurs. This creates an implicit contract between method and caller without needing explicit parameters.

**&block:** Using `&block` in a method parameter captures the block as a Proc object. This converts the syntactic construct into a runtime object. The `&` tells Ruby to convert any block passed to the method into a Proc that can be stored, passed around, or invoked later. This bridges the gap between blocks and Procs.

**Closures:** Blocks, Procs, and lambdas are closures—they capture references to variables in their surrounding scope. These captured variables remain accessible even after the scope ends. Closures capture variables by reference, not by value, so changes to captured variables are visible in the closure.

**Proc:** A Proc is an object representing encapsulated code. It's flexible with arguments—extra arguments are dropped, missing ones become nil. Procs are forgiving and convenient. They're true objects, so they can be stored, passed around, inspected, and invoked with the `call` method. They retain closure semantics.

**Lambda:** A lambda is a special Proc with stricter semantics. It enforces exact argument counts and returns only from itself, not from the enclosing method. Lambdas act more like traditional functions with defined input/output contracts. They're safer for use in larger programs where error checking matters.

**Return Behavior:** The biggest difference is return. In a Proc, `return` exits the enclosing method. In a lambda, `return` only exits the lambda itself. This makes Procs tightly integrated with their defining method's control flow. Lambdas are self-contained and don't interfere with the caller's control flow.

---
