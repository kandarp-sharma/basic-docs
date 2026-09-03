## 7. Ruby Performance

**Object Allocation:** Every object has a header with type information and takes memory. Object allocation involves memory allocation and initialization. Creating many objects has memory costs. Garbage collection is triggered by memory pressure. High allocation rates are a common performance issue.

**Garbage Collection:** Ruby uses mark-and-sweep garbage collection, often with generational collection (assuming young objects die faster). GC has a cost: it pauses execution. High allocation rates cause frequent GC. Reducing allocation is often more effective than GC tuning.

**Memory Optimization:** Use symbols instead of strings for fixed values (symbols are interned and shared). Freeze strings to avoid copying. Use lazy evaluation to avoid creating collections unnecessarily. Choose appropriate data structures. Always measure before optimizing.

**Frozen Objects:** Frozen objects can't be modified. Ruby may optimize frozen objects or intern them. Frozen strings don't need copying. Frozen objects are more predictable and enable certain optimizations. Useful for values that shouldn't change.

**Lazy Enumerators:** Lazy evaluation defers computation until values are needed. Lazy enumerators don't create intermediate collections; they evaluate one element at a time. Essential for infinite sequences and memory efficiency. The trade-off is slightly higher overhead per element.

**Benchmarking:** Measure code execution time rather than guessing. Microbenchmarks measure small segments; macrobenchmarks measure overall performance. Statistical significance requires multiple runs. Measure first, optimize the bottleneck, verify optimizations help.

---
