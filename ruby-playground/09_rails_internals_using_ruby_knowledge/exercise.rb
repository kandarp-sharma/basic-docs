puts "=== Rails Internals Using Ruby Knowledge Playground ==="

# ============================================================
# 1. Mini ActiveSupport::Concern
# ============================================================

puts "\n=== 1. ActiveSupport::Concern ==="

module MiniConcern
  def self.extended(base)
    base.instance_variable_set(:@included_block, nil)
    base.instance_variable_set(:@class_methods_module, nil)
  end

  def included(base = nil, &block)
    if base
      base.class_eval(&@included_block) if @included_block
      base.extend(@class_methods_module) if @class_methods_module
    else
      @included_block = block
    end
  end

  def class_methods(&block)
    @class_methods_module = Module.new(&block)
  end

  def append_features(base)
    base.class_eval(&@included_block) if @included_block
    base.extend(@class_methods_module) if @class_methods_module
    super
  end
end

module Trackable
  extend MiniConcern

  included do
    puts "Trackable included in #{self}"
  end

  def created_at
    "Today"
  end

  def updated_at
    "Yesterday"
  end

  class_methods do
    def tracking_enabled?
      true
    end
  end
end


# ============================================================
# 2. Callback System
# ============================================================

puts "\n=== 2. Rails-style Callbacks ==="

module CallbackClassMethods
  def before_save(method_name)
    @before_save_callbacks ||= []
    @before_save_callbacks << method_name
  end

  def before_save_callbacks
    @before_save_callbacks || []
  end
end

module CallbackInstanceMethods
  def run_callbacks(callback_name)
    callbacks = self.class.send("#{callback_name}_callbacks")
    callbacks.each do |method_name|
      send(method_name)
    end
  end
end


# ============================================================
# 3. Validation System
# ============================================================

puts "\n=== 3. Rails-style Validations ==="

module ValidationSupport
  def validates(attribute, presence: false)
    @validations ||= []
    @validations << {
      attribute: attribute,
      presence: presence
    }

  end

  def validations
    @validations || []
  end
end


# ============================================================
# 4. Scope System
# ============================================================

puts "\n=== 4. Rails-style Scopes ==="

module ScopeSupport
  def scope(name, callable)
    define_singleton_method(name) do
      callable.call
    end
  end
end


# ============================================================
# 5. Association System
# ============================================================

puts "\n=== 5. Rails-style Associations ==="

module AssociationSupport
  def has_many(name)
    define_method(name) do
      instance_variable_get("@#{name}") ||
        instance_variable_set("@#{name}", [])
    end
  end

  def belongs_to(name)
    define_method(name) do
      instance_variable_get("@#{name}")
    end

    define_method("#{name}=") do |object|
      instance_variable_set("@#{name}", object)
    end
  end
end


# ============================================================
# 6. Mini ActiveRecord Base
# ============================================================

puts "\n=== 6. Mini ActiveRecord Base ==="


class ApplicationRecord
  extend CallbackClassMethods
  include CallbackInstanceMethods
  extend ValidationSupport
  extend ScopeSupport
  extend AssociationSupport

  def save
    puts "Starting save..."
    run_callbacks(:before_save)
    if valid?
      puts "Saving #{self.class} to database"
      true
    else
      puts "Validation failed"
      false
    end
  end

  def valid?
    self.class.validations.each do |validation|
      if validation[:presence]
        value =
          send(validation[:attribute])
        if value.nil? || value.to_s.empty?
          puts "#{validation[:attribute]} can't be blank"
          return false
        end
      end
    end
    true
  end
end


# ============================================================
# 7. User Model
# ============================================================

puts "\n=== 7. User Model ==="


class User < ApplicationRecord
  include Trackable

  attr_accessor :name
  attr_accessor :email

  has_many :posts

  validates :name, presence: true
  validates :email, presence: true

  before_save :normalize_email

  scope :active, -> {
    puts "Executing User.active scope"
    ["John", "Mike"]
  }

  def initialize(name, email)
    @name = name
    @email = email
  end

  def normalize_email
    puts "Running normalize_email"
    self.email = email.downcase
  end
end


# ============================================================
# 8. Post Model
# ============================================================

puts "\n=== 8. Post Model ==="

class Post < ApplicationRecord
  belongs_to :user

  attr_accessor :title

  def initialize(title)
    @title = title
  end
end


# ============================================================
# 9. ActiveRecord DSL
# ============================================================

puts "\n=== 9. ActiveRecord DSL ==="

puts "User is a subclass of ApplicationRecord:"
puts "User.superclass => #{User.superclass}"

puts "\nRails-style DSL calls have configured metadata:"
puts "User.validations => #{User.validations}"
puts "User.before_save_callbacks => #{User.before_save_callbacks}"


# ============================================================
# 10. Associations
# ============================================================

puts "\n=== 10. Associations ==="

user = User.new(
  "John",
  "JOHN@EXAMPLE.COM"
)

post1 = Post.new("Ruby Internals")
post2 = Post.new("Rails Internals")

post1.user = user
post2.user = user

user.posts << post1
user.posts << post2

puts "user.posts => #{user.posts}"
puts "\npost1.user.inspect => #{post1.user.inspect}"
puts "\npost2.user.inspect => #{post2.user.inspect}"


# ============================================================
# 11. Validations
# ============================================================

puts "\n=== 11. Validations ==="

puts "user.valid? => #{user.valid?}"

invalid_user =
  User.new(
    "",
    ""
  )

puts "invalid_user.valid? => #{invalid_user.valid?}"


# ============================================================
# 12. Callbacks
# ============================================================

puts "\n=== 12. Callbacks ==="

puts "Before save email => #{user.email}"
user.save
puts "After save email => #{user.email}"


# ============================================================
# 13. Scopes
# ============================================================

puts "\n=== 13. Scopes ==="

puts "User.active => #{User.active}"


# ============================================================
# 14. Generated Methods
# ============================================================

puts "\n=== 14. Generated Methods ==="

puts "user responds to posts? => #{user.respond_to?(:posts)}"
puts "post1 responds to user? => #{post1.respond_to?(:user)}"
puts "post1 responds to user=? => #{post1.respond_to?(:user=)}"
puts "User responds to active? => #{User.respond_to?(:active)}"


# ============================================================
# 15. Method Ownership
# ============================================================

puts "\n=== 15. Method Ownership ==="

puts "user.method(:created_at).owner => #{user.method(:created_at).owner}"
puts "user.method(:posts).owner => #{user.method(:posts).owner}"
puts "post1.method(:user).owner => #{post1.method(:user).owner}"
puts "User.method(:active).owner => #{User.method(:active).owner}"


# ============================================================
# 16. Singleton Class
# ============================================================

puts "\n=== 16. Singleton Class ==="

puts "User.singleton_class.instance_methods(false) => #{User.singleton_class.instance_methods(false)}"
puts "User.singleton_class.ancestors => [" + "\n\t" + User.singleton_class.ancestors.join("\n\t") + "\n]"


# ============================================================
# 17. Instance Method Table
# ============================================================

puts "\n=== 17. Instance Method Table ==="

puts "User.instance_methods(false) => #{ User.instance_methods(false)}"
puts "ApplicationRecord.instance_methods(false) => #{ ApplicationRecord.instance_methods(false)}"


# ============================================================
# 18. Ancestor Chain
# ============================================================

puts "\n=== 18. Ancestor Chain ==="

puts "User.ancestors => #{User.ancestors}"
puts "Post.ancestors => #{Post.ancestors}"


# ============================================================
# 19. Rails Magic Behind the Scenes
# ============================================================

puts "\n=== 19. Rails Magic Behind the Scenes ==="

puts <<~TEXT
Rails-style code:
        class User < ApplicationRecord
          has_many :posts

          validates :email, presence: true

          before_save :normalize_email

          scope :active, -> {
            ...
          }
        end

        Conceptually:

        has_many
           |
           +--> define_method
           |
           +--> association metadata


        validates
           |
           +--> validation metadata
           |
           +--> valid?


        before_save
           |
           +--> callback metadata
           |
           +--> callback execution


        scope
           |
           +--> define_singleton_method
           |
           +--> User.active


        ActiveSupport::Concern
           |
           +--> include
           +--> extend
           +--> class_eval
           +--> append_features


        Rails DSL
           |
           v
        Ruby methods
           |
           v
        Metadata
           |
           v
        Dynamic behavior
TEXT


# ============================================================
# 20. Ruby Mechanisms Used by Rails
# ============================================================

puts <<~TEXT

=== 20. Ruby Mechanisms Used by Rails ===

        include
        extend
        prepend
        define_method
        define_singleton_method
        class_eval
        instance_eval
        append_features
        blocks
        Proc
        closures
        singleton classes
        method lookup
        method ownership
        method_missing
        callbacks
        metadata
TEXT


# ============================================================
# 21. Complete Flow
# ============================================================

puts <<~TEXT

=== 21. Complete Rails-style Flow ===

        User.new
           |
           v
        User instance
           |
           +--> has_many :posts
           |
           +--> validations
           |
           +--> callbacks
           |
           +--> Trackable methods
           |
           v
        user.save
           |
           v
        before_save callbacks
           |
           v
        valid?
           |
           v
        database persistence
TEXT

puts "\n=== Finished ==="