# Rails Database Dump & Restore with Rake

This example defines custom Rake tasks for **dumping and restoring a PostgreSQL database** in a Rails application.

File:

```text
lib/tasks/db.rake
```

## Complete Example

```ruby
namespace :db do

  desc "Dumps the database to db/APP_NAME.dump"
  task dump: :environment do
    cmd = nil

    with_config do |app, host, db, user|
      cmd = "pg_dump --host #{host} --username #{user} " \
            "--verbose --clean --no-owner --no-acl " \
            "--format=c #{db} > #{Rails.root}/db/#{app}.dump"
    end

    puts cmd
    exec cmd
  end

  desc "Restores the database dump at db/APP_NAME.dump."
  task restore: :environment do
    cmd = nil

    with_config do |app, host, db, user|
      cmd = "pg_restore --verbose --host #{host} " \
            "--username #{user} --clean --no-owner --no-acl " \
            "--dbname #{db} #{Rails.root}/db/#{app}.dump"
    end

    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke

    puts cmd
    exec cmd
  end

  private

  def with_config
    yield(
      Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:host],
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username]
    )
  end

end
```

---

# What Is a Rake Task?

Rake is Ruby's task runner.

Rails provides many built-in tasks:

```bash
bin/rails db:create
bin/rails db:drop
bin/rails db:migrate
bin/rails db:seed
```

You can create your own tasks inside:

```text
lib/tasks/
```

For example:

```text
lib/tasks/db.rake
```

Then run:

```bash
bin/rails db:dump
bin/rails db:restore
```

---

# 1. Defining the Namespace

```ruby
namespace :db do
```

The namespace groups related tasks together.

Inside this namespace:

```ruby
task dump: :environment
task restore: :environment
```

become:

```bash
bin/rails db:dump
bin/rails db:restore
```

The namespace is useful because Rails already has many database-related tasks.

---

# 2. `:environment`

```ruby
task dump: :environment do
```

The `:environment` dependency loads the Rails application environment before executing the task.

This means objects such as:

```ruby
Rails.root
ActiveRecord::Base
Rails.application
```

are available.

Without the environment, Rails-specific configuration may not be loaded.

---

# 3. The `db:dump` Task

```ruby
desc "Dumps the database to db/APP_NAME.dump"
task dump: :environment do
```

The task creates a PostgreSQL database dump using:

```bash
pg_dump
```

The generated dump is stored under:

```text
db/
```

---

# 4. Reading the Database Configuration

The task calls:

```ruby
with_config do |app, host, db, user|
```

The helper method provides four values:

```text
app  → Rails application name
host → PostgreSQL host
db   → database name
user → database username
```

These values come from the Active Record database configuration.

---

# 5. The `with_config` Helper

```ruby
def with_config
  yield(
    Rails.application.class.parent_name.underscore,
    ActiveRecord::Base.connection_config[:host],
    ActiveRecord::Base.connection_config[:database],
    ActiveRecord::Base.connection_config[:username]
  )
end
```

`yield` passes the configuration values to the block:

```ruby
with_config do |app, host, db, user|
  # use configuration here
end
```

Conceptually:

```text
with_config
    │
    ├── application name
    ├── database host
    ├── database name
    └── database username
             │
             ↓
        Rake task block
```

---

# 6. `pg_dump`

The dump command is constructed using:

```bash
pg_dump
```

Example structure:

```bash
pg_dump \
  --host HOST \
  --username USER \
  --verbose \
  --clean \
  --no-owner \
  --no-acl \
  --format=c \
  DATABASE
```

## Important options

### `--host`

```bash
--host HOST
```

Specifies the PostgreSQL server.

---

### `--username`

```bash
--username USER
```

Specifies the PostgreSQL user.

---

### `--verbose`

```bash
--verbose
```

Provides detailed output while the dump is running.

---

### `--clean`

```bash
--clean
```

Includes commands in the dump to drop database objects before recreating them during restoration.

---

### `--no-owner`

```bash
--no-owner
```

Does not include ownership commands in the dump.

This can make restoring the dump easier when the target environment uses a different database user.

---

### `--no-acl`

```bash
--no-acl
```

Does not include access-control/privilege commands.

---

### `--format=c`

```bash
--format=c
```

Creates a PostgreSQL **custom-format dump**.

This format is intended to be restored with:

```bash
pg_restore
```

---

# 7. Redirecting the Dump to a File

The command contains:

```bash
> #{Rails.root}/db/#{app}.dump
```

The `>` shell operator redirects the output into a file.

Conceptually:

```text
PostgreSQL Database
        │
        │ pg_dump
        ↓
   database dump
        │
        ↓
db/application_name.dump
```

---

# 8. `exec cmd`

The task ends with:

```ruby
puts cmd
exec cmd
```

`puts cmd` displays the command.

```ruby
puts cmd
```

is useful for seeing what command is about to run.

Then:

```ruby
exec cmd
```

replaces the current Ruby process with the shell command.

In this case, the command is `pg_dump`.

---

# 9. The `db:restore` Task

The restore task uses:

```bash
pg_restore
```

```ruby
task restore: :environment do
```

Its purpose is to restore the previously generated dump.

The basic flow is:

```text
Existing database
       │
       ↓
    db:drop
       │
       ↓
   db:create
       │
       ↓
   pg_restore
       │
       ↓
Restored database
```

---

# 10. `pg_restore`

The restore command uses:

```bash
pg_restore
```

Example structure:

```bash
pg_restore \
  --verbose \
  --host HOST \
  --username USER \
  --clean \
  --no-owner \
  --no-acl \
  --dbname DATABASE \
  db/application_name.dump
```

Because the dump was created using:

```bash
--format=c
```

it can be restored using:

```bash
pg_restore
```

---

# 11. Dropping and Creating the Database

Before restoring:

```ruby
Rake::Task["db:drop"].invoke
Rake::Task["db:create"].invoke
```

This performs:

```text
db:drop
   ↓
Delete existing database

db:create
   ↓
Create empty database

pg_restore
   ↓
Restore dump
```

### ⚠️ Important

`db:drop` is destructive.

It permanently removes the database being targeted.

Therefore, this type of restore task should be used carefully, particularly when working with production configuration.

---

# 12. Running the Tasks

Dump the database:

```bash
bin/rails db:dump
```

Restore the database:

```bash
bin/rails db:restore
```

You can also use:

```bash
bundle exec rake db:dump
bundle exec rake db:restore
```

In modern Rails applications, `bin/rails` is generally preferred.

---

# 13. What Happens During a Dump?

When you run:

```bash
bin/rails db:dump
```

the process is approximately:

```text
Rails starts
   │
   ↓
Loads Rails environment
   │
   ↓
Reads Active Record configuration
   │
   ├── host
   ├── database
   └── username
   │
   ↓
Builds pg_dump command
   │
   ↓
Runs pg_dump
   │
   ↓
Creates .dump file
```

---

# 14. What Happens During a Restore?

When you run:

```bash
bin/rails db:restore
```

the process is:

```text
Rails starts
   │
   ↓
Loads Rails environment
   │
   ↓
Reads database configuration
   │
   ↓
Builds pg_restore command
   │
   ↓
Drops database
   │
   ↓
Creates database
   │
   ↓
Runs pg_restore
   │
   ↓
Database restored
```

---

# 15. Why Use a Database Dump?

Database dumps are useful for:

- Backing up development databases
- Sharing development data between environments
- Reproducing bugs locally
- Moving PostgreSQL databases
- Restoring a known database state
- Creating a local copy of a database

For example:

```text
Development Database
        │
        │ pg_dump
        ↓
   application.dump
        │
        │ pg_restore
        ↓
Another PostgreSQL Database
```

---

# 16. Security Considerations

Be careful with database dumps.

A dump may contain:

- User records
- Emails
- Application data
- Internal business data
- Authentication-related data
- Other sensitive information

Do not commit sensitive production database dumps to a public Git repository.

For example, consider adding dump files to `.gitignore`:

```gitignore
# PostgreSQL database dumps
*.dump
```

If dumps need to be shared, use an appropriate secure storage mechanism.

---

# 17. Shell Command Safety

The example constructs a shell command using interpolated values:

```ruby
cmd = "pg_dump --host #{host} --username #{user} ..."
```

This is convenient, but shell commands should be constructed carefully when values can contain unexpected characters.

For production-quality tooling, consider using Ruby's `system` with argument arrays or `Open3` rather than building one large shell string.

For example:

```ruby
system(
  "pg_dump",
  "--host", host,
  "--username", user,
  "--verbose",
  "--clean",
  "--no-owner",
  "--no-acl",
  "--format=c",
  db
)
```

This avoids relying on shell parsing for individual arguments.

---

# 18. Key Ruby Concepts Used

This Rake task demonstrates several useful Ruby/Rails concepts:

### Namespace

```ruby
namespace :db do
```

Groups related Rake tasks.

### Task dependency

```ruby
task dump: :environment
```

Loads the Rails environment first.

### Block

```ruby
with_config do |app, host, db, user|
  # ...
end
```

Receives values from the helper method.

### `yield`

```ruby
def with_config
  yield(...)
end
```

Passes values into the supplied block.

### String interpolation

```ruby
"database: #{db}"
```

Inserts Ruby values into strings.

### `exec`

```ruby
exec cmd
```

Runs an external command by replacing the current process.

### Rake task invocation

```ruby
Rake::Task["db:drop"].invoke
```

Runs another Rake task from inside a task.

---

# Quick Reference

```text
File:
lib/tasks/db.rake

Tasks:
bin/rails db:dump
bin/rails db:restore

Dump:
Rails config
     ↓
pg_dump
     ↓
db/application_name.dump

Restore:
db:drop
     ↓
db:create
     ↓
pg_restore
     ↓
Restored database
```

## Core Commands

```bash
# Create PostgreSQL dump
pg_dump

# Restore PostgreSQL custom-format dump
pg_restore

# Run Rails Rake task
bin/rails db:dump
bin/rails db:restore
```

## Key Takeaway

This custom Rake task connects **Rails database configuration** with PostgreSQL's `pg_dump` and `pg_restore` utilities.

```text
Rails
  │
  │ ActiveRecord configuration
  ↓
Rake Task
  │
  ├── pg_dump ──────→ .dump file
  │
  └── pg_restore ←── .dump file
```

The main benefit is convenience: database backup and restoration can be performed using simple Rails commands instead of manually constructing PostgreSQL commands each time.