## 8. Ruby Standard Library

**Enumerable:** A mixin providing functional programming methods to any class implementing `each`. Methods like `map`, `select`, `reduce` are combinations of the primitive `each` operation. Provides transformation, selection, reduction, and inspection methods. Enables readable, expressive code.

**Comparable:** Provides comparison and ordering methods based on a single `<=>` method. The `<=>` method returns -1, 0, or 1 for less than, equal, or greater than. Comparable provides `<`, `<=`, `==`, `>=`, `>` based on this. Enables sorting and comparison operations.

**Set:** Provides unordered collections of unique elements using hash-based storage. Enforces uniqueness. Supports set operations: union, intersection, difference. Used for efficient membership testing, deduplication, and modeling collections that naturally don't allow duplicates.

**Struct:** A class generator creating simple classes with specified attributes. Provides getters, setters, initialization, and equality. Methods can be added via a block. Reduces boilerplate for simple data classes without creating numerous small classes manually.

**OpenStruct:** Creates objects with arbitrary attributes stored in a hash. Method calls are converted to hash access. Attributes can be added dynamically. Performance is worse than Struct due to `method_missing` overhead. Used when you don't know attributes in advance.

**Mutex:** Provides mutual exclusion for critical sections. Ensures only one thread holds its lock at a time. Other threads block waiting. Prevents race conditions in shared data. It's a tradeoff: safety vs. performance.

**Thread:** Represents concurrent execution of code. Ruby's GIL (Global Interpreter Lock) ensures only one thread executes Ruby code at a time. I/O operations allow other threads to run. Threading enables concurrency even on single-core systems via time slicing.

**Fiber:** Provides lightweight, explicitly scheduled concurrency (coroutines). Lighter than threads with no OS scheduling. Control switches explicitly. Non-preemptive: one fiber must explicitly yield. A single thread can run many fibers. Used for explicit control flow and producing value sequences.

---
