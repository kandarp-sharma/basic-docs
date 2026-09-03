puts "=== Ruby Scope & Constant Lookup Playground ==="

puts "\n=== 1. Nested Module Style ==="

module Admin
  NAME = "Admin Constant"

  module Users
    puts "Module.nesting inside Admin::Users:"
    puts "Module.nesting => #{Module.nesting}"
    puts "NAME => #{NAME}"
  end
end


puts "\n=== 2. Namespace Style ==="

module Shop
  TITLE = "Shop Constant"
end

module Shop::Products
  puts "Module.nesting inside Shop::Products:"
  puts "Module.nesting => #{Module.nesting}"

  begin
    puts "TITLE => #{TITLE}"
  rescue NameError => e
    puts "TITLE lookup error => #{e.message}"
  end
end


puts "\n=== 3. Constant Lookup Chain ==="

class User
  ROLE = "User Role"

  def self.show_role
    ROLE
  end
end

puts "User::ROLE => #{User::ROLE}"
puts "User.show_role => #{User.show_role}"

begin
  puts User.ROLE
rescue NoMethodError => e
  puts "User.ROLE error => #{e.message}"
end


puts "\n=== 4. class_eval Scope ==="

module Config
  VALUE = "Config Value"

  User.class_eval do
    puts "Inside class_eval"
    puts "Module.nesting => #{Module.nesting}"

    begin
      puts "VALUE => #{VALUE}"
    rescue NameError => e
      puts "VALUE lookup error => #{e.message}"
    end
  end
end


puts "\n=== 5. Closure with class_eval ==="

module Settings
  PREFIX = "Hello"

  User.class_eval do
    define_method(:greeting) do
      "#{PREFIX} Ruby"
    end
  end
end

user = User.new
puts "user.greeting => #{user.greeting}"


puts "\n=== 6. Instance Eval ==="

user.instance_eval do
  def singleton_method_example
    "Only this object"
  end
end

puts "user.singleton_method_example => #{user.singleton_method_example}"


puts "\n=== 7. Ancestor vs Constant Lookup ==="

module A
  VALUE = "A"

  module B
    def self.test
      puts "Constant lookup:"
      puts "VALUE => #{VALUE}"
    end
  end
end

A::B.test

puts "\n=== 8. Method Tables ==="

class Account

  def save
    "saving"
  end

  def self.find
    "finding"
  end

end

puts "Account.instance_methods(false) => #{Account.instance_methods(false)}"
puts "Account.singleton_class.instance_methods(false) => #{Account.singleton_class.instance_methods(false)}"


puts "\n=== 9. Method Lookup Chain ==="

module A
  def hello
    "A"
  end
end


module B
  def hello
    "B"
  end
end


module Override
  def hello
    "Override -> #{super}"
  end
end

class Customer
  prepend Override

  include A
  include B

  def hello
    "Customer"
  end
end

customer = Customer.new


puts "customer.hello => #{customer.hello}"
puts "Customer.ancestors => #{Customer.ancestors}"
puts "customer.method(:hello).owner => #{customer.method(:hello).owner}"


puts "\n=== 10. Runtime Method Replacement ==="

class Product
  def price
    "old price"
  end
end

product = Product.new

puts "product.price before method replacement => #{product.price}"

class Product
  def price
    "new price"
  end
end

puts "product.price after method replacement => #{product.price}"


puts "\n=== 11. Ruby VM Bytecode ==="

code = <<~RUBY
  user = "John"
  puts user
RUBY

puts "code => \n#{code}"

puts "\nRubyVM::InstructionSequence.compile(code).disasm =>"
puts RubyVM::InstructionSequence.compile(code).disasm

puts "\n=== Finished ==="
