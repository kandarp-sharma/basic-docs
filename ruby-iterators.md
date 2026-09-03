# Ruby Collection & Enumerable Methods

A practical cheat sheet for commonly used Ruby `Array` and `Enumerable` methods.

---

## `map`

Performs an operation on each array element and returns a **new array containing the results**.

The original array is not modified.

```ruby
[1, 2, 3, 4, 5].map { |e| e * 3 }
# => [3, 6, 9, 12, 15]
```

Think:

> "Transform every element."

---

## `each`

Executes a block for each element.

It returns the **original array**, not the results produced by the block.

```ruby
[1, 2, 3].each { |e| print "#{e}!" }
# prints: 1!2!3!

# => [1, 2, 3]
```

Think:

> "Do something with every element."

### `map` vs `each`

```ruby
[1, 2, 3].map { |e| e * 2 }
# => [2, 4, 6]

[1, 2, 3].each { |e| e * 2 }
# => [1, 2, 3]
```

Use `map` when you want the **transformed values**.

Use `each` when you simply want to **perform an action**.

---

## `collect`

`collect` is an alias for `map`.

```ruby
[1, 2, 3].collect { |e| e * 2 }
# => [2, 4, 6]
```

Usually, `map` is preferred because it is more commonly used and immediately recognizable.

---

## `inject`

`inject` combines elements using an **accumulator** and returns the final accumulator value.

```ruby
[1, 2, 3, 4, 5].inject { |sum, e| sum + e }
# => 15
```

The process is approximately:

```text
sum = 1
sum = 1 + 2
sum = 3 + 3
sum = 6 + 4
sum = 10 + 5

=> 15
```

### With an initial value

You can provide the initial accumulator value before the block:

```ruby
["bar", "baz", "quux"].inject("foo") do |acc, elem|
  acc + "!!" + elem
end

# => "foo!!bar!!baz!!quux"
```

---

# `select`

Returns elements for which the block evaluates to `true`.

This is commonly called **filtering** in other programming languages.

```ruby
[1, 2, 3, 4, 5, 6].select { |el| el.even? }
# => [2, 4, 6]
```

Think:

> "Keep the elements that match my condition."

---

# `find`

Returns the **first element** for which the block evaluates to `true`.

```ruby
[1, 2, 3, 4, 5].find { |el| el > 2 }
# => 3
```

If no element matches:

```ruby
[1, 2, 3].find { |el| el > 10 }
# => nil
```

Think:

> "Give me the first matching element."

---

## `detect`

`detect` is an alias for `find`.

```ruby
[1, 2, 3, 4].detect { |el| el.even? }
# => 2
```

---

# `reject`

The opposite of `select`.

It returns elements for which the block evaluates to `false`.

```ruby
[1, 2, 3, 4, 5].reject { |e| e.even? }
# => [1, 3, 5]
```

Example:

```ruby
[1, 2, 3, 4, 5, 6].reject { |e| e == 2 || e == 5 }
# => [1, 3, 4, 6]
```

Think:

> "`select` what matches; `reject` what matches."

---

# `partition`

Splits a collection into **two arrays**:

1. Elements for which the condition is `true`
2. Elements for which the condition is `false`

```ruby
[2, 3, 4, 5].partition { |e| e.even? }
# => [[2, 4], [3, 5]]
```

You can assign the results:

```ruby
even, odd = [1, 2, 3, 4, 5].partition(&:even?)

even
# => [2, 4]

odd
# => [1, 3, 5]
```

Think:

> "Split the collection into matching and non-matching elements."

---

# `reduce`

`reduce` is an alias for `inject`.

It is one of the most important methods in functional programming and is also known as **fold**.

The idea is to use an **accumulator** to build a final result.

The accumulator can be:

- A number
- A string
- An array
- A hash
- Almost anything

### Sum

```ruby
[1, 2, 3].reduce(0) { |acc, e| acc + e }
# => 6
```

Here:

```text
Initial accumulator = 0

0 + 1 = 1
1 + 2 = 3
3 + 3 = 6
```

### Without an initial value

```ruby
[1, 2, 3].reduce { |acc, e| acc + e }
# => 6
```

When the initial value is omitted, Ruby uses the **first element** as the initial accumulator.

```text
acc = 1

1 + 2 = 3
3 + 3 = 6
```

### Using a symbol

For simple operations, you can use:

```ruby
[1, 2, 3].reduce(:+)
# => 6
```

Or:

```ruby
[1, 2, 3].reduce(&:+)
# => 6
```

### Multiplication

```ruby
[2, 3, 4].reduce { |acc, e| acc * e }
# => 24
```

```ruby
[0, 2, 3, 4].reduce { |acc, e| acc * e }
# => 0
```

### `inject` vs `reduce`

They are aliases:

```ruby
[1, 2, 3].inject(:+)
# => 6

[1, 2, 3].reduce(:+)
# => 6
```

---

# `all?`

Returns `true` if **all elements** satisfy the condition.

```ruby
[2, 4, 6].all? { |e| e.even? }
# => true
```

Example:

```ruby
[2, 4, 5].all? { |e| e.even? }
# => false
```

Think:

> "Does every element match?"

---

# `any?`

Returns `true` if **at least one element** satisfies the condition.

```ruby
[3, 8, 42].any? { |e| e > 10 }
# => true
```

Think:

> "Does at least one element match?"

### Without a block

You can also use `any?` to check whether the collection contains a truthy value:

```ruby
[3, 4].any?
# => true

[].any?
# => false

[nil].any?
# => false

[false].any?
# => false
```

Ruby treats `nil` and `false` as falsy. Everything else is truthy.

---

# `times`

`times` executes a block a specified number of times.

```ruby
3.times do
  puts "Hello world!"
end

# Hello world!
# Hello world!
# Hello world!
```

You can also get the current iteration index:

```ruby
3.times do |i|
  puts i
end

# 0
# 1
# 2
```

Notice that the index starts at **0**.

---

# Sorting Methods

## `sort`

Sorts elements in their natural order.

```ruby
[7, 2, 5].sort
# => [2, 5, 7]
```

Strings:

```ruby
["c", "b", "a"].sort
# => ["a", "b", "c"]
```

---

## `sort_by`

`sort_by` is useful when you want to sort objects based on a particular attribute.

For example:

```ruby
employees.sort_by { |e| e.last_name }
```

This sorts employees by their `last_name`.

You can also use the shorter symbol-to-proc syntax:

```ruby
employees.sort_by(&:last_name)
```

---

# But... I Want Indexes!

Sometimes you need both:

- The current element
- The current index

Ruby provides several ways to do this.

## `each_with_index`

```ruby
["a", "b", "c"].each_with_index do |element, index|
  puts "#{index}: #{element}"
end
```

Output:

```text
0: a
1: b
2: c
```

---

## `map.with_index`

You can also access the index while using `map`:

```ruby
["a", "b", "c"].map.with_index do |element, index|
  "#{index}: #{element}"
end

# => ["0: a", "1: b", "2: c"]
```

This is useful when you need to **transform** the elements while also knowing their indexes.

---

# Combining Collection Methods

Ruby collection methods become particularly powerful when you combine them.

For example:

```ruby
["coconut", "lemon", "banana", "apple"]
  .select { |e| e.size > 5 }
  .map { |e| e.upcase }
  .sort
```

Step by step:

### 1. `select`

Keep strings longer than 5 characters:

```ruby
["coconut", "banana"]
```

### 2. `map`

Convert them to uppercase:

```ruby
["COCONUT", "BANANA"]
```

### 3. `sort`

Sort alphabetically:

```ruby
["BANANA", "COCONUT"]
```

Final result:

```ruby
# => ["BANANA", "COCONUT"]
```

---

# Quick Reference

| Method | Purpose | Returns |
|---|---|---|
| `map` | Transform every element | New array |
| `each` | Perform an action on every element | Original collection |
| `collect` | Alias for `map` | New array |
| `inject` | Accumulate a result | Final accumulator |
| `reduce` | Alias for `inject` | Final accumulator |
| `select` | Keep matching elements | New array |
| `find` | Find first matching element | Element or `nil` |
| `detect` | Alias for `find` | Element or `nil` |
| `reject` | Remove matching elements | New array |
| `partition` | Split by condition | Two arrays |
| `all?` | Do all elements match? | `true` / `false` |
| `any?` | Does at least one match? | `true` / `false` |
| `times` | Repeat an action | Integer |
| `sort` | Sort elements | New array |
| `sort_by` | Sort using a calculated key | New array |
| `each_with_index` | Iterate with index | Collection |
| `map.with_index` | Transform with index | New array |

---

# Mental Model

```text
map
  ↓
Transform everything

each
  ↓
Do something with everything

select
  ↓
Keep what matches

reject
  ↓
Remove what matches

find
  ↓
Get the first match

partition
  ↓
Split into matches + non-matches

reduce
  ↓
Combine everything into one result

all?
  ↓
Does everything match?

any?
  ↓
Does anything match?

sort / sort_by
  ↓
Order the collection
```

## The Most Important Ones to Master

If you're learning Ruby, focus on these first:

```ruby
map       # transform
each      # iterate
select    # filter
find      # first match
reject    # remove matches
reduce    # accumulate
any?      # at least one?
all?      # everything?
sort_by   # sort by something
```

Once these become familiar, a lot of Ruby code becomes much easier to read and write.