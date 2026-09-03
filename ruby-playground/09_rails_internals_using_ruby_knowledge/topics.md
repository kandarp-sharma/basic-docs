## 9. Rails Internals

**ActiveSupport::Concern:** Encapsulates the pattern of providing both instance and class methods via module inclusion. Automates the ClassMethods pattern, reducing boilerplate. Makes module definitions cleaner with an `included` block for setup code.

**Rails Callbacks:** Execute at specific lifecycle points in an object's lifecycle. Multiple callbacks can be registered for the same event. Separate business logic from side effects. Provide predictable extension points without modifying core code.

**ActiveRecord DSL:** Uses class methods as macros that generate instance methods and setup associations. Called at class definition time, they modify the class and its behavior. Methods like `has_many`, `validates`, `scope` generate code dynamically.

**Scopes:** Reusable query patterns. Class methods that return relations. Relations are chainable for building complex queries. Queries are lazy—executed when you iterate or call methods needing results. Composable query building with separation of query logic.

**Validations:** Constraints ensuring data meets rules before persistence. Registered via class methods. Multiple validations per attribute. Custom validations can be defined. Run before saving; errors collected prevent save.

**Associations:** Relationships between models declared via macros. Generate methods for accessing related objects. Types include one-to-many, one-to-one, many-to-many, and polymorphic. Enable eager loading to optimize queries.

**Rails Magic:** Uses method generation for accessors, handles missing methods for dynamic finders, executes callbacks at lifecycle points, converts data between Ruby and database types, lazy loads expensive operations. Sophisticated integration throughout the framework.

---
