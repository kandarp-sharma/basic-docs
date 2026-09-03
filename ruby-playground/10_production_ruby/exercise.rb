puts "=== Ruby Production Skills Playground ==="


# ============================================================
# 1. Gem-like Architecture
# ============================================================

puts "\n=== 1. Gem-like Architecture ==="

module UserTools
  VERSION = "1.0.0"

  module Formatter
    def formatted_name
      "#{name.upcase} <#{email}>"
    end
  end

  module Validator
    def valid_email?
      email.include?("@")
    end
  end
end

puts "UserTools::VERSION => #{UserTools::VERSION}"
puts "UserTools::Formatter => #{UserTools::Formatter}"
puts "UserTools::Validator => #{UserTools::Validator}"


# ============================================================
# 2. Application Class
# ============================================================

puts "\n=== 2. Application Class ==="

class User
  attr_reader :name
  attr_reader :email

  def initialize(name, email)
    @name = name
    @email = email
  end

  def greeting
    "Hello #{name}"
  end

  def active?
    true
  end
end

user = User.new(
  "John",
  "john@example.com"
)

puts "user.name => #{user.name}"
puts "user.email => #{user.email}"
puts "user.greeting => #{user.greeting}"
puts "user.active? => #{user.active?}"


# ============================================================
# 3. Gem-style Module Inclusion
# ============================================================

puts "\n=== 3. Gem-style Module Inclusion ==="

User.include(UserTools::Formatter)
User.include(UserTools::Validator)

puts "user.formatted_name => #{user.formatted_name}"
puts "user.valid_email? => #{user.valid_email?}"

puts "\nUser ancestors => #{User.ancestors}"


# ============================================================
# 4. Safe Monkey Patching with prepend
# ============================================================

puts "\n=== 4. Safe Monkey Patching ==="

module UserLoggingPatch
  def greeting
    puts "[LOG] User#greeting called"
    super
  end
end

User.prepend(UserLoggingPatch)

puts "Calling user.greeting => #{user.greeting}"
puts "User ancestors after prepend => #{User.ancestors}"


# ============================================================
# 5. Dangerous Monkey Patching
# ============================================================

puts "\n=== 5. Dangerous Monkey Patching ==="

puts <<~TEXT
Ruby classes are open.

Example:
class String
  def custom_method
    ...
  end
end

This changes String globally.

Avoid changing fundamental methods such as:
String#upcase
Array#map
Hash#fetch

Prefer isolated modules, prepend, or refinements.
TEXT


# ============================================================
# 6. Refinements
# ============================================================

puts "\n=== 6. Refinements ==="

module StringProductionExtensions
  refine String do
    def production_tag
      "[#{self}]"
    end
  end
end

puts "Outside refinement:"

begin
  puts "Ruby".production_tag
rescue NoMethodError
  puts "production_tag unavailable"
end

class ProductionFormatter
  using StringProductionExtensions

  def format(name)
    name.production_tag
  end
end

formatter = ProductionFormatter.new
puts "Inside refined class => #{formatter.format("Ruby")}"


# ============================================================
# 7. Method Owner
# ============================================================

puts "\n=== 7. Method Owner ==="

puts "user.method(:greeting).owner => #{user.method(:greeting).owner}"
puts "user.method(:formatted_name).owner => #{user.method(:formatted_name).owner}"
puts "user.method(:valid_email?).owner => #{user.method(:valid_email?).owner}"
puts "user.method(:active?).owner => #{user.method(:active?).owner}"


# ============================================================
# 8. Method Source Location
# ============================================================

puts "\n=== 8. Method Source Location ==="

puts "greeting source_location => #{user.method(:greeting).source_location}"
puts "formatted_name source_location => #{user.method(:formatted_name).source_location}"
puts "active? source_location => #{user.method(:active?).source_location}"


# ============================================================
# 9. Native Ruby Method Inspection
# ============================================================

puts "\n=== 9. Native Ruby Method Inspection ==="

puts "String#upcase owner => #{'hello'.method(:upcase).owner}"
puts "String#upcase source_location => #{'hello'.method(:upcase).source_location}"
puts "Array#map owner => #{[].method(:map).owner}"
puts "Array#map source_location => #{[].method(:map).source_location}"


# ============================================================
# 10. Ancestor Inspection
# ============================================================

puts "\n=== 10. Ancestor Inspection ==="

puts "User.ancestors => #{User.ancestors}"
puts "User singleton_class ancestors => #{User.singleton_class.ancestors}"


# ============================================================
# 11. Singleton Class
# ============================================================

puts "\n=== 11. Singleton Class ==="


User.define_singleton_method(:application_name) do
  "Production Ruby App"
end

puts "User.application_name => #{User.application_name}"
puts "User.method(:application_name).owner => #{User.method(:application_name).owner}"
puts "User.singleton_class.instance_methods(false) => #{User.singleton_class.instance_methods(false)}"


# ============================================================
# 12. Idiomatic Ruby - map
# ============================================================

puts "\n=== 12. Idiomatic Ruby - map ==="

users = [
  User.new("John", "john@example.com"),
  User.new("Mike", "mike@example.com"),
  User.new("Alex", "alex@example.com")
]

names = users.map(&:name)

puts "users.map(&:name) => #{names}"


# ============================================================
# 13. Idiomatic Ruby - select
# ============================================================

puts "\n=== 13. Idiomatic Ruby - select ==="

active_users = users.select(&:active?)
puts "users.select(&:active?) => #{active_users.map(&:name)}"


# ============================================================
# 14. Idiomatic Ruby - any?
# ============================================================

puts "\n=== 14. Idiomatic Ruby - any? ==="

puts "users.any?(&:active?) => #{users.any?(&:active?)}"


# ============================================================
# 15. Idiomatic Ruby - nil?
# ============================================================

puts "\n=== 15. Idiomatic Ruby - nil? ==="

value = nil
puts "value.nil? => #{value.nil?}"


# ============================================================
# 16. Safe Navigation
# ============================================================

puts "\n=== 16. Safe Navigation ==="

account = nil
puts "account&.name => #{account&.name}"


# ============================================================
# 17. Keyword Arguments
# ============================================================

puts "\n=== 17. Keyword Arguments ==="

def create_user(name:, email:)
  {
    name: name,
    email: email
  }
end

result = create_user(
  name: "Sarah",
  email: "sarah@example.com"
)

puts "create_user result => #{result}"


# ============================================================
# 18. Method Introspection
# ============================================================

puts "\n=== 18. Method Introspection ==="

method = user.method(:greeting)

puts "method => #{method}"
puts "method.name => #{method.name}"
puts "method.owner => #{method.owner}"
puts "method.source_location => #{method.source_location}"
puts "method.parameters => #{method.parameters}"


# ============================================================
# 19. Object / Class / Singleton Class
# ============================================================

puts "\n=== 19. Object / Class / Singleton Class ==="

puts "user.class => #{user.class}"
puts "user.class.class => #{user.class.class}"
puts "User.class => #{User.class}"
puts "User.singleton_class => #{User.singleton_class}"
puts "User.singleton_class.superclass => #{User.singleton_class.superclass}"


# ============================================================
# 20. Production Debugging Flow
# ============================================================

puts "\n=== 20. Production Debugging Flow ==="

puts <<~TEXT
1. Identify the receiver.
2. Find the method.
   object.method(:name)
3. Find the owner.
   object.method(:name).owner
4. Find the source.
   object.method(:name).source_location
5. Inspect ancestors.
   object.class.ancestors
6. Inspect singleton class.
   object.singleton_class.ancestors
7. Check method_missing when required.
TEXT


# ============================================================
# 21. Production Ruby Summary
# ============================================================

puts "\n=== 21. Production Ruby Summary ==="

puts <<~TEXT
Gem Architecture
Monkey Patching
prepend
Refinements
Method Introspection
Source Location
Ancestor Inspection
Singleton Classes
Idiomatic Enumerable
Safe Navigation
Keyword Arguments
TEXT

puts "=== Finished ==="