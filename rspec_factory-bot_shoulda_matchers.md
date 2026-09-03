# Rails Testing Gems: RSpec, Factory Bot & Shoulda Matchers

These three gems are commonly used together for testing Ruby on Rails applications.

## 1. RSpec Rails

```ruby
gem "rspec-rails"
```

**Purpose:** Testing framework for Rails.

RSpec lets you write and run tests using a readable syntax.

```ruby
RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = User.new(name: "John", email: "john@example.com")

    expect(user).to be_valid
  end
end
```

Run tests:

```bash
bundle exec rspec
```

RSpec provides:

- `describe`
- `context`
- `it`
- `expect`
- Matchers such as `eq`, `be_valid`, `include`, etc.

---

## 2. Factory Bot Rails

```ruby
gem "factory_bot_rails"
```

**Purpose:** Easily create test data.

Instead of repeatedly writing:

```ruby
User.create!(
  name: "John",
  email: "john@example.com"
)
```

Define a factory:

```ruby
# spec/factories/users.rb

FactoryBot.define do
  factory :user do
    name { "John" }
    email { "john@example.com" }
  end
end
```

Then use it in tests:

```ruby
user = create(:user)
```

Customize attributes:

```ruby
user = create(:user, name: "Alice")
```

Create multiple records:

```ruby
users = create_list(:user, 5)
```

Factory Bot helps keep test data setup **short, reusable, and consistent**.

---

## 3. Shoulda Matchers

```ruby
gem "shoulda-matchers"
```

**Purpose:** Provides simple matchers for common Rails behavior.

For example:

```ruby
class User < ApplicationRecord
  belongs_to :company

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
```

Instead of manually testing every validation and association:

```ruby
RSpec.describe User, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }

  it { should belong_to(:company) }
end
```

Common matchers:

```ruby
validate_presence_of
validate_uniqueness_of
validate_length_of

belong_to
have_many
have_one
have_many_attached
have_one_attached
```

---

# How They Work Together

```text
RSpec
  │
  │  Runs the tests
  ↓
Factory Bot
  │
  │  Creates test data
  ↓
Shoulda Matchers
  │
  │  Provides Rails-specific shortcuts
  ↓
Rails Application
```

Example:

```ruby
RSpec.describe User, type: :model do
  # Shoulda Matchers
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should belong_to(:company) }

  # Factory Bot + RSpec
  it "creates a valid user" do
    user = create(:user)

    expect(user).to be_valid
  end
end
```

## Quick Summary

| Gem | What it does |
|---|---|
| `rspec-rails` | Writes and runs tests |
| `factory_bot_rails` | Creates test records |
| `shoulda-matchers` | Tests common Rails validations/associations |

### Remember

**RSpec = Test framework**

**Factory Bot = Test data**

**Shoulda Matchers = Rails test shortcuts**