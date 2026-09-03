require "benchmark"
require "objspace"


puts "=== Ruby Performance Playground ==="

# ============================================================
# 1. Object Allocation
# ============================================================

puts "\n=== 1. Object Allocation ==="

puts "\nString allocation"

a = "ruby"
b = "ruby"

puts "a.object_id => #{a.object_id}"
puts "b.object_id => #{b.object_id}"

puts "Same String object?"
puts a.object_id == b.object_id

puts "\nSymbol allocation"

x = :ruby
y = :ruby

puts "x.object_id => #{x.object_id}"
puts "y.object_id => #{y.object_id}"

puts "Same Symbol object?"
puts x.object_id == y.object_id

puts "\nChecking String allocations"

before = GC.stat[:total_allocated_objects]

10000.times do
  "hello"
end

after = GC.stat[:total_allocated_objects]

puts "Objects created:"
puts after - before


# ============================================================
# 2. Garbage Collection
# ============================================================

puts "\n=== 2. Garbage Collection ==="

puts "\nGC statistics before allocation"

puts "GC count:"
puts GC.stat[:count]

puts "Creating temporary objects"

100000.times do
  Object.new
end

puts "\nGC statistics after allocation"

puts "GC count:"
puts GC.stat[:count]

puts "Live objects:"
puts GC.stat[:heap_live_slots]

puts "\nRunning manual GC"

GC.start

puts "Live objects after GC:"
puts GC.stat[:heap_live_slots]


# ============================================================
# 3. Memory Optimization
# ============================================================

puts "\n=== 3. Memory Optimization ==="

puts "\nBad approach - creating strings repeatedly"

before = GC.stat[:total_allocated_objects]

10000.times do
  message = "Hello Ruby"
end

after = GC.stat[:total_allocated_objects]

puts "Allocated objects:"
puts after - before


puts "\nBetter approach - reuse frozen constant"

MESSAGE = "Hello Ruby".freeze

before = GC.stat[:total_allocated_objects]

10000.times do
  message = MESSAGE
end

after = GC.stat[:total_allocated_objects]

puts "Allocated objects:"
puts after - before


# ============================================================
# 4. Frozen Objects
# ============================================================

puts "\n=== 4. Frozen Objects ==="

name = "Ruby"

puts "Before freeze:"
puts name.frozen?

name.freeze

puts "After freeze:"
puts name.frozen?

begin
  name << " Rails"
rescue => e
  puts "Modification error:"
  puts e.class
end

puts "\nFrozen Hash example"

config = {
  environment: "production"
}

config.freeze

puts "Hash frozen?"
puts config.frozen?

puts "Nested String frozen?"
puts config[:environment].frozen?


# ============================================================
# 5. Lazy Enumerators
# ============================================================

puts "\n=== 5. Lazy Enumerators ==="

puts "\nNormal Enumerator"

result = (1..5).map do |number|
  puts "Processing #{number}"
  number * 2
end

puts "Result:"
p result

puts "\nLazy Enumerator"

result =
  (1..100)
  .lazy
  .map do |number|
    puts "Processing #{number}"
    number * 2
  end
  .first(3)

puts "Lazy result:"
p result


puts "\nEnumerator classes"

puts "[1,2,3].each.class"
puts [1,2,3].each.class

puts "[1,2,3].lazy.class"
puts [1,2,3].lazy.class


puts "\nInfinite lazy sequence"

numbers =
  (1..Float::INFINITY)
  .lazy

p numbers.first(10)



# ============================================================
# 6. Benchmarking
# ============================================================

puts "\n=== 6. Benchmarking ==="

require "benchmark"

def concat_method(name)
  "Hello " + name
end

def interpolation_method(name)
  "Hello #{name}"
end

name = "Ruby"

# ------------------------------------------------------------
# Benchmark.measure
# ------------------------------------------------------------

puts "\n=== Benchmark.measure ==="

time = Benchmark.measure do
  100000.times do
    concat_method(name)
  end
end

puts time

# ------------------------------------------------------------
# Benchmark.realtime
# ------------------------------------------------------------

puts "\n=== Benchmark.realtime ==="

elapsed = Benchmark.realtime do
  100000.times do
    interpolation_method(name)
  end
end

puts "Execution time:"
puts "#{elapsed} seconds"

# ------------------------------------------------------------
# Benchmark.bm
# ------------------------------------------------------------

puts "\n=== Benchmark.bm ==="

Benchmark.bm do |x|
  x.report("concat") do
    100000.times do
      concat_method(name)
    end
  end

  x.report("interpolation") do
    100000.times do
      interpolation_method(name)
    end
  end
end

# ------------------------------------------------------------
# Benchmark.bmbm
# ------------------------------------------------------------

puts "\n=== Benchmark.bmbm ==="

Benchmark.bmbm do |x|
  x.report("Array creation") do
    100000.times do
      [1,2,3,4,5]
    end
  end

  x.report("Hash creation") do
    100000.times do
      {
        a: 1,
        b: 2
      }
    end
  end
end

# ------------------------------------------------------------
# Allocation Benchmark
# ------------------------------------------------------------

puts "\n=== Allocation Benchmark ==="

before = GC.stat[:total_allocated_objects]

10000.times do
  "hello ruby"
end

after = GC.stat[:total_allocated_objects]

puts "Allocated objects:"
puts after - before


# ------------------------------------------------------------
# Benchmark IPS
# ------------------------------------------------------------

puts "\n=== Benchmark IPS (Optional) ==="

puts <<~TEXT
benchmark-ips is not part of Ruby standard library.

Install:
gem install benchmark-ips

Example:
require "benchmark/ips"

Benchmark.ips do |x|
  x.report("concat") do
    "a" + "b"
  end

  x.report("interpolation") do
    "#{"a"}#{"b"}"
  end

  x.compare!
end

Output:
concat          10M i/s
interpolation    8M i/s

TEXT


# ============================================================
# ObjectSpace Inspection
# ============================================================

puts "\n=== ObjectSpace Inspection ==="

puts "String count:"
puts ObjectSpace.count_objects[:T_STRING]

puts "Array count:"
puts ObjectSpace.count_objects[:T_ARRAY]

puts "Hash count:"
puts ObjectSpace.count_objects[:T_HASH]


puts "\n=== Final GC Stats ==="

p GC.stat.slice(
  :count,
  :heap_live_slots,
  :total_allocated_objects
)

puts "\n=== Finished ==="