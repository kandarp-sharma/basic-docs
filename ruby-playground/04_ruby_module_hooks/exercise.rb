puts "=== Ruby Module Hooks Playground ==="

module Trackable
  def self.included(base)
    puts "Trackable included in #{base}"
    base.extend(ClassMethods)
  end

  def self.extended(base)
    puts "Trackable extended in #{base}"
  end

  def self.prepended(base)
    puts "Trackable prepended in #{base}"
  end

  def save
    "Trackable instance save"
  end

  def instance_track
    "Trackable instance method"
  end

  module ClassMethods
    def track
      "Trackable class method"
    end

    def class_info
      "Class method from ClassMethods module"
    end
  end
end

puts "\n=== Include Pattern ==="

class User
  include Trackable

  def save
    "User save"
  end
end

user = User.new

puts "user.instance_track => #{user.instance_track}"

begin
  puts user.track
rescue NoMethodError => e
  puts "user.track error => #{e.message}"
end

puts "User.track => #{User.track}"
puts "User.class_info => #{User.class_info}"

puts "\n=== Method Ownership ==="

puts "user.method(:instance_track).owner => #{user.method(:instance_track).owner}"
puts "User.method(:track).owner => #{User.method(:track).owner}"

puts "\n=== Ancestors ==="

puts "User.ancestors => #{User.ancestors}"
puts "User.singleton_class.ancestors => #{User.singleton_class.ancestors}"

puts "\n=== Extend Pattern ==="

module Auditable
  def audit
    "Auditable class method"
  end
end

class Account
  extend Auditable
end

puts "Account.audit => #{Account.audit}"

puts "\n=== Prepend Pattern ==="

module OverrideSave
  def save
    "OverrideSave before -> #{super}"
  end
end

class Post
  prepend OverrideSave

  def save
    "Post save"
  end
end

post = Post.new

puts "post.save => #{post.save}"
puts "Post.ancestors => #{Post.ancestors}"

puts "\n=== ActiveSupport::Concern Style Simulation ==="

module Searchable
  def self.included(base)
    base.extend(ClassMethods)
  end

  def search
    "instance searching"
  end

  module ClassMethods
    def indexed_columns
      [:name, :email]
    end
  end
end

class Customer
  include Searchable
end

customer = Customer.new

puts "customer.search => #{customer.search}"
puts "Customer.indexed_columns => #{Customer.indexed_columns}"

puts "\n=== Inspection ==="

puts "Trackable.instance_methods(false) => #{Trackable.instance_methods(false)}"
puts "Trackable::ClassMethods.instance_methods(false) => #{Trackable::ClassMethods.instance_methods(false)}"


puts "\n=== MiniConcern Playground ==="

module MiniConcern
  def self.extended(base)
    base.instance_variable_set(:@included_block, nil)
    base.instance_variable_set(:@class_methods_module, nil)
  end

  def included(base = nil, &block)
    @included_block = block
  end

  def class_methods(&block)
    @class_methods_module = Module.new(&block)
  end

  def append_features(base)
    super

    base.class_eval(&@included_block) if @included_block
    base.extend(@class_methods_module) if @class_methods_module
  end
end


module TrackableModule
  extend MiniConcern

  included do
    puts "Included block executed inside #{self}"
  end

  def created_at
    "Today"
  end

  def updated_at
    "Yesterday"
  end

  class_methods do
    def table_name
      "users"
    end

    def count_records
      100
    end
  end
end


class UserClass
  include TrackableModule
end


user = UserClass.new

puts "\n=== Instance Methods ==="

puts "user.created_at => #{user.created_at}"
puts "user.updated_at => #{user.updated_at}"

puts "\n=== Class Methods ==="

puts "UserClass.table_name => #{UserClass.table_name}"
puts "UserClass.count_records => #{UserClass.count_records}"

puts "\n=== Ownership ==="

puts "created_at owner => #{user.method(:created_at).owner}"
puts "table_name owner => #{UserClass.method(:table_name).owner}"

puts "\n=== Ancestors ==="

puts "UserClass.ancestors => #{UserClass.ancestors}"
puts "UserClass.singleton_class.ancestors => #{UserClass.singleton_class.ancestors}"

puts "=== Finished ==="
