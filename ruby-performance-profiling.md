# Ruby Application Performance Profiling

Profiling helps identify **performance bottlenecks** in a Ruby application by showing where the application spends CPU time, allocates memory, or performs expensive operations.

---

## Profiling Tools

### `ruby-prof`

**Purpose:** Detailed CPU profiling.

Useful for finding:

- Which methods consume the most CPU time
- How many times methods are called
- Call-stack information
- Expensive methods and code paths

Install:

```bash
gem install ruby-prof
```

Profile a Ruby program:

```bash
ruby-prof my_program.rb
```

Example:

```ruby
# my_program.rb

def expensive_operation
  1_000_000.times do
    Math.sqrt(rand)
  end
end

expensive_operation
```

Run:

```bash
ruby-prof my_program.rb
```

The output can help identify where most of the execution time is being spent.

**Best for:** Detailed CPU/method-level profiling.

---

## `stackprof`

**Purpose:** Lightweight sampling profiler.

`stackprof` periodically samples the Ruby call stack instead of tracing every method call.

This makes it useful for profiling larger applications, especially **Rails applications**, with relatively low overhead.

Install:

```bash
gem install stackprof
```

Example:

```ruby
require "stackprof"

StackProf.run(mode: :cpu, out: "tmp/stackprof.dump") do
  # Code you want to profile
  100_000.times do
    "hello".upcase
  end
end
```

Then inspect the profile:

```bash
stackprof tmp/stackprof.dump
```

You can also generate a graphical visualization depending on your workflow.

**Best for:** Finding hot code paths with low profiling overhead.

---

# `benchmark`

**Purpose:** Measure the execution time of specific Ruby code.

Ruby's standard library provides the `benchmark` library.

```ruby
require "benchmark"

time = Benchmark.measure do
  1_000_000.times do
    "hello".upcase
  end
end

puts time
```

You can compare different implementations:

```ruby
require "benchmark"

Benchmark.bm do |x|
  x.report("map") do
    100_000.times { [1, 2, 3].map { |n| n * 2 } }
  end

  x.report("each") do
    100_000.times do
      result = []
      [1, 2, 3].each { |n| result << n * 2 }
    end
  end
end
```

**Best for:** Measuring a specific piece of code.

---

# `benchmark-ips`

**Purpose:** Compare Ruby implementations based on **iterations per second**.

`benchmark-ips` is useful when you want to know which implementation performs better.

Install:

```bash
gem install benchmark-ips
```

Example:

```ruby
require "benchmark/ips"

Benchmark.ips do |x|
  x.report("map") do
    [1, 2, 3].map { |n| n * 2 }
  end

  x.report("each") do
    result = []
    [1, 2, 3].each { |n| result << n * 2 }
  end

  x.compare!
end
```

The result tells you approximately how many times each implementation can execute per second.

**Best for:** Comparing alternative implementations and micro-optimizations.

> `benchmark` answers: **"How long does this take?"**
>
> `benchmark-ips` answers: **"How many times can this run per second?"**

---

# `memory_profiler`

**Purpose:** Identify excessive object allocations and memory usage.

CPU performance isn't always the problem. Ruby applications can also become slow because they create too many objects or consume too much memory.

Install:

```bash
gem install memory_profiler
```

Example:

```ruby
require "memory_profiler"

report = MemoryProfiler.report do
  100_000.times do
    "hello".upcase
  end
end

report.pretty_print
```

It can help identify:

- Number of allocated objects
- Memory allocated
- Objects retained
- Allocation sources
- Classes responsible for allocations

**Best for:** Investigating memory usage and excessive allocations.

---

# `derailed_benchmarks`

**Purpose:** Benchmark and profile Rails applications.

`derailed_benchmarks` is particularly useful for investigating:

- Rails application boot time
- Memory usage
- Gem-related memory impact
- Request performance
- Application performance regressions

Install:

```bash
gem install derailed_benchmarks
```

It is commonly used from within a Rails application.

For example:

```bash
bundle exec derailed exec perf:mem
```

You can use its various tasks to investigate memory and performance characteristics of a Rails application.

**Best for:** Rails-specific performance and memory investigations.

---

# YJIT Profiling

Ruby's **YJIT** (Yet Another Ruby JIT) is a just-in-time compiler designed to improve Ruby execution performance.

When investigating performance under YJIT, Ruby provides YJIT statistics and profiling capabilities.

Depending on the Ruby version and runtime configuration, you may encounter options such as:

```bash
ruby --yjit-stats my_program.rb
```

YJIT statistics can provide information useful for understanding:

- JIT compilation behavior
- Code execution under YJIT
- Compilation effectiveness
- Runtime performance characteristics

Check the YJIT options supported by your installed Ruby version:

```bash
ruby --help
```

**Best for:** Understanding performance when running Ruby with YJIT enabled.

> YJIT options and statistics can vary between Ruby versions, so always check the documentation for the Ruby version you're running.

---

# Typical Profiling Workflow

Don't immediately optimize random code.

A better workflow is:

```text
1. Identify a performance problem
          ↓
2. Measure the current performance
          ↓
3. Profile the application
          ↓
4. Find the bottleneck
          ↓
5. Optimize the bottleneck
          ↓
6. Benchmark again
          ↓
7. Verify that performance improved
```

---

## Step 1: Benchmark

For a small piece of code:

```ruby
require "benchmark"

puts Benchmark.measure do
  # Code to measure
end
```

For comparing implementations:

```ruby
require "benchmark/ips"

Benchmark.ips do |x|
  # implementations
end
```

---

## Step 2: CPU Profiling

Install `ruby-prof`:

```bash
gem install ruby-prof
```

Run:

```bash
ruby-prof my_program.rb
```

Use the results to identify methods consuming significant CPU time.

---

## Step 3: Sampling Profiling

For a larger application:

```ruby
StackProf.run(mode: :cpu, out: "tmp/stackprof.dump") do
  # Application code
end
```

Then:

```bash
stackprof tmp/stackprof.dump
```

This can help identify **hot call paths** without the overhead of tracing every method.

---

## Step 4: Check Memory

If CPU isn't the main issue, investigate allocations:

```ruby
require "memory_profiler"

report = MemoryProfiler.report do
  # Code to investigate
end

report.pretty_print
```

Look for unexpectedly large numbers of allocated objects or excessive memory usage.

---

## Step 5: Rails-Specific Investigation

For Rails applications, use tools such as:

```bash
bundle exec derailed exec perf:mem
```

This can help investigate application memory usage and the impact of dependencies.

---

# Choosing the Right Tool

| Tool | Primary Purpose | Best Use Case |
|---|---|---|
| `ruby-prof` | CPU profiling | Find expensive methods |
| `stackprof` | Sampling CPU profiler | Find hot paths |
| `benchmark` | Execution time | Measure specific code |
| `benchmark-ips` | Iterations/sec | Compare implementations |
| `memory_profiler` | Memory allocations | Find allocation/memory problems |
| `derailed_benchmarks` | Rails profiling | Rails memory/boot/performance |
| YJIT stats | JIT profiling | Investigate YJIT performance |

---

# Important Rule: Measure Before Optimizing

Avoid assumptions such as:

```text
"This method looks slow, so I'll optimize it."
```

Instead:

```text
Measure
  ↓
Profile
  ↓
Find bottleneck
  ↓
Optimize
  ↓
Measure again
```

A profiler may reveal that the code you expected to be slow is actually insignificant, while a completely different method is responsible for most of the runtime.

---

# Quick Cheat Sheet

### CPU / Method-level profiling

```bash
gem install ruby-prof
ruby-prof my_program.rb
```

### Sampling profiler

```ruby
StackProf.run(mode: :cpu, out: "tmp/stackprof.dump") do
  # code
end
```

```bash
stackprof tmp/stackprof.dump
```

### Simple benchmarking

```ruby
require "benchmark"

Benchmark.measure do
  # code
end
```

### Compare implementations

```ruby
require "benchmark/ips"

Benchmark.ips do |x|
  x.report("version A") { /* code */ }
  x.report("version B") { /* code */ }
  x.compare!
end
```

### Memory profiling

```ruby
require "memory_profiler"

report = MemoryProfiler.report do
  # code
end

report.pretty_print
```

### Rails profiling

```bash
bundle exec derailed exec perf:mem
```

### YJIT

```bash
ruby --yjit --yjit-stats my_program.rb
```

---

# Summary

```text
ruby-prof
    ↓
Detailed CPU profiling

stackprof
    ↓
Lightweight CPU sampling

benchmark
    ↓
Measure execution time

benchmark-ips
    ↓
Compare implementations

memory_profiler
    ↓
Find memory allocations

derailed_benchmarks
    ↓
Rails performance & memory

YJIT stats
    ↓
Understand performance under YJIT
```

**Golden rule:**

> **Don't optimize what you haven't measured. Profile first, identify the bottleneck, then optimize.**