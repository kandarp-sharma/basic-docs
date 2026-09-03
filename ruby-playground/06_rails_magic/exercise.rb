puts "=== Rails Magic Playground ==="

module RailsMagic
  # ==================================
  # attr_accessor clone
  # ==================================
  def my_attr_accessor(attribute)
    define_method(attribute) do
      instance_variable_get("@#{attribute}")
    end

    define_method("#{attribute}=") do |value|
      instance_variable_set("@#{attribute}", value)
    end
  end

  # ==================================
  # scope clone
  # ==================================
  def my_scope(name, callable)
    define_singleton_method(name) do
      callable.call
    end
  end

  # ==================================
  # validates clone
  # ==================================
  def my_validates(attribute, options)
    @validations ||= []
    @validations << {
      attribute: attribute,
      options: options
    }

    define_method(:valid?) do
      self.class.validations.all? do |validation|
        if validation[:options][:presence]
          value = send(validation[:attribute])
          !value.nil? && value != ""
        end
      end
    end
  end

  def validations
    @validations || []
  end

  # ==================================
  # delegate clone
  # ==================================
  def my_delegate(method_name, to:)
    define_method(method_name) do
      target = send(to)
      target.send(method_name)
    end
  end

  # ==================================
  # belongs_to clone
  # ==================================
  def my_belongs_to(name)
    define_method(name) do
      instance_variable_get("@#{name}")
    end

    define_method("#{name}=") do |object|
      instance_variable_set("@#{name}", object)
    end
  end

  # ==================================
  # has_many clone
  # ==================================
  def my_has_many(name)
    define_method(name) do
      instance_variable_get("@#{name}") || []
    end

    define_method("#{name}=") do |objects|
      instance_variable_set("@#{name}", objects)
    end
  end

  # ==================================
  # callbacks clone
  # ==================================
  def before_save(method_name)
    @before_save_callbacks ||= []
    @before_save_callbacks << method_name

    define_method(:run_callbacks) do |callback_name|
      callbacks = self.class.send(callback_name)
      callbacks.each do |method|
        send(method)
      end
    end
  end

  def before_save_callbacks
    @before_save_callbacks || []
  end
end

# ============================
# Models
# ============================
class Profile
  extend RailsMagic

  my_attr_accessor :name
end

class Post
  extend RailsMagic

  my_attr_accessor :title

  my_belongs_to :user
end

class User
  extend RailsMagic

  my_attr_accessor :name

  my_has_many :posts

  my_belongs_to :profile

  my_scope :active, -> {
    "Active users"
  }

  my_validates :name, presence: true

  before_save :normalize_name

  def normalize_name
    self.name = name.downcase
    puts "normalize_name callback executed"
  end

  def save
    run_callbacks(:before_save_callbacks)
    puts "User saved"
  end
end

# ============================
# Testing
# ============================
puts "\n=== has_many ==="

user = User.new
post1 = Post.new
post1.title = "Post 1"

post2 = Post.new
post2.title = "Post 2"

user.posts = [post1, post2]

puts "user.posts.inspect => #{user.posts.inspect}"


puts "\n=== belongs_to ==="

post1.user = user

puts "post1.user.name => #{post1.user.name}"


puts "\n=== delegate style relation ==="

profile = Profile.new
profile.name = "John"

user.profile = profile

puts "user.profile.name => #{user.profile.name}"


puts "\n=== scope ==="

puts "User.active => #{User.active}"


puts "\n=== validation ==="

user.name = "John"

puts "user.valid? => #{user.valid?}"


puts "\n=== callbacks ==="

puts "user.save =>"
user.save


puts "\n=== Ownership ==="

puts "posts owner:"
puts "user.method(:posts).owner => #{user.method(:posts).owner}"

puts "user owner on Post:"
puts "post1.method(:user).owner => #{post1.method(:user).owner}"


puts "\n=== Method Tables ==="

puts "User instance methods:"
puts "User.instance_methods(false) => #{User.instance_methods(false)}"

puts "\nUser singleton methods:"
puts "User.singleton_class.instance_methods(false) => #{User.singleton_class.instance_methods(false)}"


puts "\n=== Ancestors ==="

puts "User.ancestors => #{User.ancestors}"
puts "User.singleton_class.ancestors => #{User.singleton_class.ancestors}"

puts "\n=== Finished ==="