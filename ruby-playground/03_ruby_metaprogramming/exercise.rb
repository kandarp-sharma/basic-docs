puts "=== Ruby Metaprogramming Playground ==="

module UserFeatures
  def feature_method
    "Module feature method"
  end
end

class User
  include UserFeatures

  def initialize(name)
    @name = name
  end

  def name
    @name
  end

  private

  def private_name
    @name
  end
end

user = User.new("John")

puts "\n=== define_method ==="

User.define_method(:dynamic_instance_method) do
  "Created using define_method"
end

puts "user.dynamic_instance_method => #{user.dynamic_instance_method}"
puts "user.method(:dynamic_instance_method).owner => #{user.method(:dynamic_instance_method).owner}"

puts "\n=== define_singleton_method ==="

User.define_singleton_method(:dynamic_class_method) do
  "Created using define_singleton_method"
end

puts "User.dynamic_class_method => #{User.dynamic_class_method}"
puts "User.method(:dynamic_class_method).owner => #{User.method(:dynamic_class_method).owner}"

puts "\n=== send ==="
puts "user.send(:name) => #{user.send(:name)}"
puts "user.send(:private_name) => #{user.send(:private_name)}"

puts "\n=== public_send ==="
puts "user.public_send(:name) => #{user.public_send(:name)}"
begin
  user.public_send(:private_name)
rescue NoMethodError => e
  public_send_method_error = "public_send method error: #{e.message}"
end
puts "user.public_send(:private_name) => #{public_send_method_error}"

puts "\n=== method_missing ==="

class User
  def method_missing(method_name, *args)
    puts "Missing method: #{method_name}"
    puts "Args: #{args.inspect}"
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.start_with?("find_by_") || super
  end
end

puts "user.find_by_email(\"test@example.com\")"
user.find_by_email("test@example.com")
puts "user.respond_to?(:find_by_email) => #{user.respond_to?(:find_by_email)}"

puts "\n=== class_eval ==="

User.class_eval do
  def class_eval_method
    "Added using class_eval"
  end
end

puts "user.class_eval_method => #{user.class_eval_method}"

puts "\n=== instance_eval ==="

user.instance_eval do
  def singleton_user_method
    "Only this object has this method"
  end
end

puts "user.singleton_user_method => #{user.singleton_user_method}"
puts "user.method(:singleton_user_method).owner => #{user.method(:singleton_user_method).owner}"

puts "\n=== Inspection ==="

puts "User.instance_methods(false) => #{User.instance_methods(false)}"
puts "User.singleton_class.instance_methods(false) => #{User.singleton_class.instance_methods(false)}"

puts "\n=== Ancestors ==="

puts "User.ancestors => #{User.ancestors}"
puts "User.singleton_class.ancestors => #{User.singleton_class.ancestors}"

puts "=== Finished ==="
