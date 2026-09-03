puts "=== Ruby Blocks, Proc, Lambda & Closure Playground ==="

puts "\n=== 1. Basic Block with yield ==="

def execute
  puts "Before block"
  yield
  puts "After block"
end

execute do
  puts "Inside block"
end


puts "\n=== 2. Block with Arguments ==="

def greet
  yield("John")
end

greet do |name|
  puts "Hello #{name}"
end


puts "\n=== 3. block_given? ==="

def optional_execute
  if block_given?
    yield
  else
    puts "No block received"
  end
end

optional_execute

optional_execute do
  puts "Block received"
end


puts "\n=== 4. Convert Block into Proc using & ==="

def run(&block)
  puts "block.class => #{block.class}"
  block.call
end

run do
  puts "Running Proc object"
end


puts "\n=== 5. yield vs block.call ==="

def using_yield
  yield
end

using_yield do
  puts "Executed using yield"
end


def using_proc(&block)
  block.call
end

using_proc do
  puts "Executed using block.call"
end


puts "\n=== 6. Closure Example ==="

def create_counter
  count = 0

  Proc.new do
    count += 1
  end
end

counter = create_counter

puts "counter.call => #{counter.call}"
puts "counter.call => #{counter.call}"
puts "counter.call => #{counter.call}"


puts "\n=== 7. Proc Argument Behavior ==="

my_proc = Proc.new do |a, b|
  puts "Proc a=#{a}, b=#{b.inspect}"
end

my_proc.call(10)


puts "\n=== 8. Lambda Argument Behavior ==="

my_lambda = ->(a, b) do
  puts "Lambda a=#{a}, b=#{b.inspect}"
end

begin
  my_lambda.call(10)
rescue ArgumentError => e
  puts "Lambda error => #{e.message}"
end


puts "\n=== 9. Proc vs Lambda Return Behavior ==="

def proc_return_example
  proc_object = Proc.new {
    puts "Inside Proc"
    return "Returned from method by Proc"
  }

  proc_object.call

  puts "After Proc"
end

puts proc_return_example


def lambda_return_example
  lambda_object = lambda {
    puts "Inside Lambda"
    return "Returned from lambda only"
  }

  result = lambda_object.call

  puts "After Lambda"

  result
end

puts lambda_return_example

puts "\n=== Summary ==="

puts <<~TEXT

Block:
- Passed to a method
- Not a normal object until converted

Proc:
- Object representation of a block
- Created using Proc.new/proc/&block
- Flexible arguments
- Non-local return

Lambda:
- Proc with method-like behavior
- Strict arguments
- Local return

Closure:
- Block remembers variables from the place where it was created

TEXT

puts "=== Finished ==="
