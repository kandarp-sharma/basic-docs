puts "=== Ruby Object Model Single Flow ==="


puts <<~TEXT

  module InstanceFeatureOne
    methods: [who_am_i, instance_one, instance_common]
  end

  module InstanceFeatureTwo
    methods: [who_am_i, instance_two, instance_common]
  end

  module ClassFeature
    method: class_feature
  end

  module OverrideFeature
    method: save with call super
  end


  class BaseModel
    methods: [who_am_i, base_method]
  end


  class User < BaseModel

    prepend OverrideFeature

    include InstanceFeatureOne
    include InstanceFeatureTwo

    extend ClassFeature

    methods: [who_am_i, initialize(name), name, save, self.class_method]
  end

TEXT

module InstanceFeatureOne
  def who_am_i
    "Feature One"
  end

  def instance_one
    "InstanceFeatureOne method"
  end

  def instance_common
    "Common method called from InstanceFeatureOne"
  end
end

module InstanceFeatureTwo
  def who_am_i
    "Feature Two"
  end

  def instance_two
    "InstanceFeatureTwo method"
  end

  def instance_common
    "Common method called from InstanceFeatureTwo"
  end
end

module ClassFeature
  def class_feature
    "ClassFeature method (extend)"
  end
end

module OverrideFeature
  def save
    puts "OverrideFeature before save (prepend)"
    super
  end
end


class BaseModel
  def who_am_i
    "Base Model"
  end

  def base_method
    "BaseModel method"
  end
end


class User < BaseModel

  prepend OverrideFeature

  include InstanceFeatureOne
  include InstanceFeatureTwo

  extend ClassFeature

  def who_am_i
    "User"
  end

  def initialize(name)
    @name = name
  end

  def name
    @name
  end

  def save
    puts "User save method"
  end

  def self.class_method
    "User class method"
  end

end


puts "\n=== Instance Method Calls ==="

user = User.new("John")

puts "user.name => #{user.name}"
puts "user.who_am_i => #{user.who_am_i}"
puts "user.instance_one => #{user.instance_one}"
puts "user.instance_two => #{user.instance_two}"
puts "user.instance_common => #{user.instance_common}"
puts "user.base_method => #{user.base_method}"


puts "\n=== Prepend Example ==="

user.save


puts "\n=== Class Method Calls ==="

puts "User.class_method => #{User.class_method}"
puts "User.class_feature => #{User.class_feature}"


puts "\n=== Where is the method coming from? ==="

puts "user.method(:who_am_i).owner => #{user.method(:who_am_i).owner}"
puts "user.method(:instance_one).owner => #{user.method(:instance_one).owner}"
puts "user.method(:instance_two).owner => #{user.method(:instance_two).owner}"
puts "user.method(:instance_common).owner => #{user.method(:instance_common).owner}"
puts "user.method(:base_method).owner => #{user.method(:base_method).owner}"
puts "User.method(:class_feature).owner => #{User.method(:class_feature).owner}"
puts "User.method(:class_method).owner => #{User.method(:class_method).owner}"
puts "user.method(:save).owner => #{user.method(:save).owner}"


puts "\n=== Ancestors ==="

puts "User ancestors:"
puts "User.ancestors => #{User.ancestors}"


puts "\nUser singleton class ancestors:"
puts "User.singleton_class.ancestors => #{User.singleton_class.ancestors}"


puts "\n=== Method Inspection ==="

puts "Methods directly inside User:"
puts "User.instance_methods(false) => #{User.instance_methods(false)}"

puts "\nMethods directly inside User singleton class:"
puts "User.singleton_class.instance_methods(false) => #{User.singleton_class.instance_methods(false)}"

puts "\nMethods directly inside InstanceFeatureOne:"
puts "InstanceFeatureOne.instance_methods(false) => #{InstanceFeatureOne.instance_methods(false)}"

puts "\nMethods directly inside ClassFeature:"
puts "ClassFeature.instance_methods(false) => #{ClassFeature.instance_methods(false)}"


puts "\n=== Lookup Summary ==="

puts <<~TEXT

Instance call:
user.method

Lookup:
User instance
  |
User
  |
InstanceFeatureTwo
  |
InstanceFeatureOne
  |
BaseModel
  |
Object


Class call:
User.method

Lookup:
#<Class:User>
  |
ClassFeature
  |
#<Class:BaseModel>
  |
Class
  |
Module


Prepend:
OverrideFeature appears before User,
so it gets control first and calls super.

TEXT

puts "\n=== Method Lookup Priority ==="

puts <<~TEXT
1. prepended modules
2. class itself
3. included modules (reverse order)
4. superclass
5. superclass modules
6. Object
7. Kernel
8. BasicObject

TEXT

puts "=== Finished ==="
