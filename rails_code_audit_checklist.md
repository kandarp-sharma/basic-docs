# My Ruby on Rails Code Audit Checklist

> A practical checklist I can use when reviewing an existing Ruby on Rails application.

## Why I Audit a Rails App

A code audit is not about finding reasons to rewrite an application.

The goal is to understand:

- What version of Ruby/Rails are we running?
- Are dependencies safe and controlled?
- Can I confidently change the code?
- Are secrets protected?
- Can I set up the application locally?
- Is the database designed for the queries we actually run?
- Where is the technical debt?
- What should I fix first?

### My priority

```text
Understand
   ↓
Measure
   ↓
Identify risks
   ↓
Prioritize
   ↓
Improve
   ↓
Re-check
```

---

# 1. Ruby Version

First, check whether the Ruby version is explicitly defined.

Look for:

```text
.ruby-version
Gemfile
```

Example:

```ruby
ruby "3.3.0"
```

Check:

```bash
ruby -v
cat .ruby-version
```

### Questions

- Is the Ruby version documented?
- Does `.ruby-version` exist?
- Does the `Gemfile` specify Ruby?
- Is the development Ruby version the same as production?
- Is the Ruby version supported?
- Is upgrading Ruby currently blocked by dependencies?

### Why it matters

Everyone should know which Ruby version the application expects.

Without this, developers can unknowingly work with different Ruby versions.

---

# 2. Gemfile & Dependencies

The `Gemfile` tells me a lot about the health of the application.

Check:

```text
Gemfile
Gemfile.lock
```

## Rails version

Make sure Rails is intentionally constrained.

```ruby
gem "rails", "~> 8.0"
```

Avoid accidentally allowing a major Rails upgrade through dependency resolution.

---

## Ruby version

Prefer documenting the Ruby version:

```ruby
ruby "3.3.0"
```

And also use:

```text
.ruby-version
```

---

## Dependency versions

Ask:

- Are important dependencies version constrained?
- Is `Gemfile.lock` committed?
- Are dependencies unnecessarily old?
- Are there abandoned gems?
- Are there duplicate gems solving the same problem?
- Are there gems that nobody understands anymore?

For unfamiliar gems, find out:

```text
Why is this gem here?
Who uses it?
Can we remove it?
```

Document unusual dependencies when useful:

```ruby
# Used for generating PDFs for customer invoices.
gem "some_pdf_gem", "~> 2.5"
```

---

## Gem groups

Development/test-only gems should generally not be installed in production.

Example:

```ruby
group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "shoulda-matchers"
end
```

Production should not need testing tools such as:

```text
rspec
factory_bot
capybara
debugging/profiling tools
```

unless there is a specific reason.

---

## HTTPS

Use:

```ruby
source "https://rubygems.org"
```

Not:

```ruby
source "http://rubygems.org"
```

---

# 3. Dependency Security

Run a dependency security audit.

A common tool is:

```bash
bundle-audit
```

Typical workflow:

```bash
bundle install
bundle-audit
```

Look for:

```text
Known vulnerabilities
CVE
Outdated vulnerable gems
Recommended upgrades
```

### My questions

- Does the application have known vulnerable dependencies?
- Are security patches being applied?
- Is dependency auditing part of CI?
- Are old gems preventing security upgrades?
- Is Rails itself on a supported/security-maintained version?

### Important

Security auditing should be **continuous**, not something I perform once during a code audit.

---

# 4. Automated Tests

Before making significant changes, I want to know:

> "Can I trust the test suite?"

Run:

```bash
bundle exec rspec
```

or:

```bash
bin/rails test
```

depending on the application.

---

## Check whether tests are actually maintained

Look at Git history:

```bash
git log -- spec/
```

Also:

```bash
git log -- test/
```

Compare test activity with application code:

```text
app/     → frequent changes
spec/    → no changes for months
```

That is a warning sign.

---

## Questions

- Do tests exist?
- Do they pass?
- Are they maintained?
- Do important business rules have tests?
- Are there integration/request tests?
- Are tests extremely slow?
- Are tests flaky?
- Are tests being skipped?
- Is test coverage meaningful?

### My preferred testing stack

For an RSpec Rails application:

```ruby
gem "rspec-rails"
gem "factory_bot_rails"
gem "shoulda-matchers"
```

Think:

```text
RSpec
  ↓
Test framework

Factory Bot
  ↓
Test data

Shoulda Matchers
  ↓
Rails-specific test shortcuts
```

---

# 5. Secrets & Credentials

This is a **high-priority security check**.

Search configuration files:

```bash
find config -type f
```

Look for:

```text
passwords
API keys
access tokens
AWS credentials
database credentials
private keys
production secrets
```

Bad:

```yaml
production:
  database_password: "my-secret-password"
  api_key: "abc123"
```

Secrets should not be committed to Git.

---

## Check Git history

Removing a secret from the current file is not enough if it was previously committed.

Ask:

```text
Was the secret ever committed?
```

If yes:

1. Rotate the credential.
2. Remove it from repository history when appropriate.
3. Verify the old credential is no longer valid.
4. Store the replacement securely.

Possible places for secrets:

```text
Environment variables
Rails credentials
Secret manager
Deployment platform secrets
Password manager
```

### Golden rule

> If a credential has been committed to Git, assume it is compromised.

---

# 6. Local Development Setup

Ask:

> "Can a new developer clone this repository and run it?"

A healthy Rails project should have a predictable setup process.

Typical steps:

```bash
git clone <repository>
cd my_app

bundle install

bin/rails db:setup

bin/rails server
```

Depending on the application, you may also need:

```bash
yarn install
npm install
docker compose up
```

---

## Database setup

Check:

```text
db/seeds.rb
db/schema.rb
db/structure.sql
db/migrate/
```

Can I create a useful local database?

```bash
bin/rails db:setup
```

Can I reset it?

```bash
bin/rails db:reset
```

Can I load development data?

```bash
bin/rails db:seed
```

---

## Avoid using production data locally

A dangerous development workflow is:

```text
Production DB backup
        ↓
Developer laptop
        ↓
Application development
```

This creates potential:

- Privacy problems
- Security problems
- Data leakage
- Accidental production-data modification
- Compliance issues

Prefer safe, synthetic development data.

---

# 7. Database & Indexes

Database performance problems often come from missing or inappropriate indexes.

Inspect:

```text
db/schema.rb
```

Look for:

```ruby
add_index :users, :email
add_index :posts, :user_id
```

---

## Foreign keys

If a table contains:

```ruby
user_id
company_id
account_id
```

ask:

> Does this column need an index?

For example:

```ruby
add_index :posts, :user_id
```

---

## But don't blindly index everything

Indexes have a cost:

```text
More indexes
    ↓
Faster reads
    +
Slower writes
    +
More storage
```

The correct question is:

> "Do the application's actual queries benefit from this index?"

---

## Composite indexes

Sometimes the query pattern requires a composite index.

For example:

```ruby
Order.where(user_id: user.id, status: "paid")
```

may benefit from:

```ruby
add_index :orders, [:user_id, :status]
```

Index decisions should be based on actual query patterns and database behavior.

---

## Check slow queries

Look for:

```text
N+1 queries
Full table scans
Missing indexes
Large joins
Unnecessary queries
Repeated queries
```

Useful Rails tools include:

```text
Rails logs
Bullet
EXPLAIN
ActiveRecord query logs
Database monitoring
```

---

# 8. TODOs & Technical Debt

Search the codebase:

```bash
grep -Rni "TODO" app/
```

Also search for:

```bash
grep -Rni "FIXME" app/
grep -Rni "HACK" app/
grep -Rni "XXX" app/
```

Don't automatically fix every TODO.

Instead classify them:

```text
TODO
 ↓
Is it still relevant?
 ↓
 ┌───────────────┐
 │               │
Yes             No
 │               │
 ↓               ↓
Prioritize      Remove
```

---

## Questions

For each TODO:

- Is it still relevant?
- Is there already another solution?
- Is it a bug?
- Is it technical debt?
- Is it performance-related?
- Is it security-related?
- Should it become a GitHub/Jira issue?
- Can it simply be deleted?

---

# 9. Code Quality

The original eight checks are a good starting point, but I also want to inspect the actual Rails architecture.

## Controllers

Watch for:

```text
Huge controllers
Complex business logic
Repeated code
Database-heavy actions
Too many callbacks
```

A controller should generally coordinate the request rather than contain the entire business domain.

---

## Models

Look for:

```text
Huge models
Too many callbacks
Complex validations
Unrelated responsibilities
Repeated scopes
```

Fat models are not automatically bad, but a model containing hundreds or thousands of lines deserves investigation.

---

## Services

Don't create service objects just because "Rails best practice" says so.

Instead ask:

> "Does this piece of business logic have a clear responsibility that belongs outside the model/controller?"

---

# 10. Performance

Before optimizing, measure.

Useful Ruby tools:

```text
ruby-prof
stackprof
benchmark
benchmark-ips
memory_profiler
derailed_benchmarks
YJIT profiling
```

Typical workflow:

```text
Performance problem
       ↓
Benchmark
       ↓
Profile
       ↓
Find bottleneck
       ↓
Optimize
       ↓
Benchmark again
```

### Never optimize based only on intuition.

The slow-looking code may not be the actual bottleneck.

---

# 11. N+1 Queries

This deserves its own check.

Example:

```ruby
@posts = Post.all
```

Then in the view:

```erb
<% @posts.each do |post| %>
  <%= post.user.name %>
<% end %>
```

This can result in:

```text
1 query for posts
+
N queries for users
```

Instead:

```ruby
@posts = Post.includes(:user)
```

Now Rails can load the associated users efficiently.

Always inspect query behavior when working with:

```text
has_many
belongs_to
has_one
```

relationships.

---

# 12. Rails Upgrade Readiness

When reviewing an older application, determine:

```text
Ruby version
Rails version
Database version
Node/runtime version if applicable
Important gem versions
```

Then ask:

```text
What prevents the next upgrade?
```

Typical blockers:

```text
Old gems
Deprecated Rails APIs
Ruby incompatibilities
Removed APIs
Unmaintained dependencies
Weak test coverage
Custom monkey patches
Old JavaScript tooling
```

A code audit should make upgrades **less risky**, not merely identify that the application is old.

---

# My Audit Priority

Not everything deserves the same urgency.

I use this rough priority:

## 🔴 Critical

Fix immediately.

```text
Exposed credentials
Known exploitable vulnerabilities
Production data exposed to developers
Broken authentication/authorization
Critical production failures
```

## 🟠 High

Address soon.

```text
Missing important database indexes
Broken/absent critical tests
Unsupported Ruby/Rails version
Severe performance problems
Unmaintained critical dependencies
```

## 🟡 Medium

Plan and improve.

```text
Technical debt
Large controllers/models
Poor test coverage
Slow CI
Old dependencies
Missing documentation
```

## 🟢 Low

Improve when convenient.

```text
Minor refactoring
Naming improvements
Old TODO comments
Style inconsistencies
Non-critical cleanup
```

---

# My Rails Audit Checklist

```text
[ ] Ruby version documented
[ ] .ruby-version exists
[ ] Rails version understood
[ ] Gemfile reviewed
[ ] Gemfile.lock reviewed
[ ] Dependencies have intentional versions
[ ] Gem groups are sensible
[ ] Unused gems identified
[ ] Unknown gems documented
[ ] HTTPS used for RubyGems source
[ ] Dependency security audit performed

[ ] Test suite exists
[ ] Test suite passes
[ ] Tests are actively maintained
[ ] Critical business logic is tested
[ ] Test coverage is meaningful
[ ] Flaky tests identified

[ ] Secrets searched for
[ ] Git history checked for leaked secrets
[ ] Exposed credentials rotated
[ ] Production credentials protected

[ ] Application can be setup locally
[ ] Database can be created locally
[ ] db/seeds.rb reviewed
[ ] Safe development data available
[ ] Production data is not required locally

[ ] Database indexes reviewed
[ ] Foreign-key indexes reviewed
[ ] Composite indexes considered
[ ] N+1 queries investigated
[ ] Slow queries investigated

[ ] TODO/FIXME/HACK comments reviewed
[ ] Technical debt identified
[ ] Controllers reviewed
[ ] Models reviewed
[ ] Business logic reviewed
[ ] Duplicate code identified

[ ] Performance measured
[ ] CPU bottlenecks investigated
[ ] Memory allocations investigated
[ ] Rails boot time considered

[ ] Rails upgrade blockers identified
[ ] Ruby upgrade blockers identified
[ ] Critical dependencies identified
```

---

# Final Audit Report

After reviewing an application, I should not produce a giant list of random problems.

I should produce something actionable:

```text
Finding
   ↓
Why it matters
   ↓
Risk
   ↓
Evidence
   ↓
Recommended action
   ↓
Priority
```

Example:

### Missing index on `orders.user_id`

**Risk:** Medium

**Evidence:**

```ruby
Order.where(user_id: current_user.id)
```

is executed frequently, but `orders.user_id` has no index.

**Impact:**

As the `orders` table grows, queries may become increasingly expensive.

**Recommendation:**

Add an index after validating query behavior:

```ruby
add_index :orders, :user_id
```

**Priority:** High if the table/query is already large or slow.

---

# The Goal

The purpose of a Rails audit is not:

```text
"Your code is bad."
```

It is:

```text
"What do we have?"
       ↓
"What risks exist?"
       ↓
"What is hurting us?"
       ↓
"What should we fix first?"
       ↓
"How can we safely improve it?"
```

A mature Rails application usually does **not** need a rewrite just because it has technical debt.

The better approach is usually:

```text
Existing application
       ↓
Understand it
       ↓
Protect it with tests
       ↓
Remove critical risks
       ↓
Improve incrementally
       ↓
Upgrade safely
       ↓
Keep auditing
```

> **My rule: preserve what works, measure what hurts, secure what is exposed, test what matters, and improve incrementally.**

---

## Source

Based on:

**Ruby on Rails Code Audits: 8 Steps to Review Your App** — Planet Argon, November 15, 2023.

[Read the original Planet Argon article](https://blog.planetargon.com/blog/entries/ruby-on-rails-code-audits-8-steps-to-review-your-app?utm_source=chatgpt.com)