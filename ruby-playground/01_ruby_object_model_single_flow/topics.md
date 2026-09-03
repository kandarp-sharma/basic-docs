## 1. Ruby Object Model

**Class vs Object:** In Ruby, classes are objects too. When you define a class with `class Dog`, you're creating an instance of the `Class` class. This means classes can have methods, instance variables, and behavior just like any object. The entire system is homogeneous—everything follows the same rules. There's no special case for classes; they're just objects with certain responsibilities.

**Instance Methods:** Instance methods are defined in a class but aren't stored in each instance. They're shared across all instances and stored once in the class. When an instance calls a method, Ruby looks it up in the class (not in the instance itself) and executes it with that instance as the receiver. This saves memory since every instance doesn't carry its own copy of methods.

**Class Methods:** Class methods are called on the class itself, not on instances. Theoretically, they're singleton methods of the class object. Since a class is an object, it can have its own singleton class (eigenclass), and methods defined there become class methods. They're specific to that class and don't affect other classes.

**Singleton Class (Eigenclass):** Every object gets a private, anonymous class called its singleton class when you define per-object methods. This sits in the method lookup chain between the object and its regular class. It allows individual objects to have unique behavior without creating new classes. Classes use their eigenclass for class methods.

**Method Lookup:** When you call a method, Ruby searches for it following a specific path: first the object's singleton class, then its class, then superclasses, then included modules, up through Object and BasicObject. If not found, it calls `method_missing`. This is deterministic and follows the C3 linearization algorithm to handle complex inheritance.

**Ancestors Chain:** The ancestors chain is the linearized sequence of classes and modules that form the method lookup path. You can see it with `ancestors`, which shows exactly where Ruby will search for methods in order. This reveals the complete inheritance and mixin hierarchy and explains method resolution order.

**Include:** When you include a module, Ruby inserts it into the ancestor chain as instance methods. It doesn't copy the methods; it adds the module to the lookup chain. Multiple modules can be included, and they form a stack. The order matters: later includes add modules closer to the class in the lookup path.

**Extend:** Extend mixes modules into the singleton class, making them singleton methods. For classes, this means they become class methods. For objects, it means they become unique to that object. Both operations work by inserting the module into the singleton class hierarchy.

**Prepend:** Prepend inserts a module before the class in the ancestor chain, opposite of include. This lets module methods override class methods while still using `super` to call the original. Perfect for wrapping or decorating existing methods.

---
