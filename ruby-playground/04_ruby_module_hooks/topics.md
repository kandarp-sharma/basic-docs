## 4. Modules Deep Dive

**Include:** Inserts a module into the ancestor chain as instance methods. The module isn't copied; it's referenced in the lookup chain. Multiple modules can be included, and they form a stack. Later includes place modules closer to the class in the lookup path.

**Extend:** Mixes a module into the singleton class, making its methods singleton methods. For classes, this creates class methods. For objects, it creates unique methods on that object. Both operations work by modifying the singleton class hierarchy.

**Prepend:** Inserts a module before the class in the ancestor chain. Methods in the prepended module are found before class methods in lookup. This enables decorator and wrapper patterns while still allowing access to the original method through `super`.

**Included Callback:** Ruby calls this hook when a module is included. It receives the class doing the including. Allows modules to react to inclusion and set up additional behavior. Often used to extend the class with class methods via the ClassMethods pattern.

**Extended Callback:** Ruby calls this when a module is extended. It receives the object being extended. Follows the same pattern as `included`, enabling modules to react to being extended.

**Prepended Callback:** Ruby calls this when a module is prepended. It receives the class being prepended to. Allows modules to react to prepending and set up appropriate behavior.

**ClassMethods Pattern:** A module defines an inner module called ClassMethods. In the `included` hook, the outer module extends the including class with ClassMethods. This provides both instance and class methods from a single module, with class methods naturally namespaced.

**ActiveSupport::Concern:** A Rails helper that automates the ClassMethods pattern. It provides an `included` block for setup code and automatically handles class method extension. Makes module definitions cleaner and more readable.

**Rails Module Architecture:** Rails uses modules extensively to add functionality. Models inherit from ApplicationRecord, which includes numerous modules for different concerns. Each module adds specific capabilities through mixins and callbacks, creating a layered architecture.

---
