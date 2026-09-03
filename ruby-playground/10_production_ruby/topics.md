## 10. Production Ruby

**Gems Architecture:** Packaged Ruby libraries with standardized structure. Gemspec defines metadata and dependencies. Code in `lib/` is loaded on require. Standard versioning uses semantic versioning. Dependencies managed through Bundler.

**Monkey Patching:** Modifying existing classes causes global changes affecting all code. Different gems might patch the same class differently. Debugging becomes harder. Updates to the original class might conflict. Solutions include refinements, composition, and contributing to projects.

**Refinements:** Local scope modifications of classes without global effects. Defined in modules and activated with `using` in specific scopes. Don't affect code outside the scope. Enable safe monkey patching without global state pollution.

**Debugging Internals:** Use introspection to examine objects and methods. Trace functions follow code execution. Profilers measure performance. Read source code to understand implementation. Tools include pry for interactive debugging and profilers for performance analysis.

**Reading Ruby Source:** Find method implementations with `source_location`. Many built-ins are in C, but documentation exists. Understand how Ruby works by reading source. GitHub has the complete Ruby source. Learn from experienced developers and examples.

**Idiomatic Ruby:** Readability over cleverness. Convention over configuration. Explicit over implicit. Fail fast and clearly. DRY principle. SOLID principles. Consistent naming and style. Ruby community values simplicity and elegance. Tests are expected. Code should be understandable to other Ruby developers.

---
