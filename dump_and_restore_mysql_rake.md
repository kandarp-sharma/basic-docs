# Rails Database Dump & Restore with Rake — MySQL

This example defines custom Rake tasks for **dumping and restoring a MySQL database** in a Rails application.

File:

```text
lib/tasks/db.rake
```

Unlike PostgreSQL, MySQL commonly uses:

```bash
mysqldump
```

to create a database dump and:

```bash
mysql
```

to restore it.

---

# Complete Example

```ruby
namespace :db do

  desc "Dumps the database to db/APP_NAME.sql"
  task dump: :environment do
    cmd = nil

    with_config do |app, host, db, user|
      cmd = "mysqldump --host=#{host} --user=#{user} " \
            "--single-transaction --routines --triggers " \
            "#{db} > #{Rails.root}/db/#{app}.sql"
    end

    puts cmd
    exec cmd
  end

  desc "Restores the database dump at db/APP_NAME.sql"
  task restore: :environment do
    cmd = nil

    with_config do |app, host, db, user|
      cmd = "mysql --host=#{host} --user=#{user} " \
            "#{db} < #{Rails.root}/db/#{app}.sql"
    end

    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke

    puts cmd
    exec cmd
  end

  private

  def with_config
    config = ActiveRecord::Base.connection_db_config.configuration_hash

    yield(
      Rails.application.class.parent_name.underscore,
      config[:host] || "localhost",
      config[:database],
      config[:username]
    )
  end

end
```

---

# What Is a Rake Task?

Rake is Ruby's task runner.

Rails provides built-in database tasks such as:

```bash
bin/rails db:create
bin/rails db:drop
bin/rails db:migrate
bin/rails db:seed
```

You can create custom tasks inside:

```text
lib/tasks/
```

For example:

```text
lib/tasks/db.rake
```

The custom tasks can then be run with:

```bash
bin/rails db:dump
bin/rails db:restore
```

---

# 1. Defining the Namespace

```ruby
namespace :db do
```

The namespace groups database-related tasks.

These:

```ruby
task dump: :environment
task restore: :environment
```

become:

```bash
bin/rails db:dump
bin/rails db:restore
```

---

# 2. `:environment`

```ruby
task dump: :environment do
```

The `:environment` dependency loads the Rails application before running the task.

This allows the task to access Rails objects such as:

```ruby
Rails.root
ActiveRecord::Base
Rails.application
```

and the application's database configuration.

---

# 3. The `db:dump` Task

```ruby
desc "Dumps the database to db/APP_NAME.sql"
task dump: :environment do
```

This task creates a MySQL database dump using:

```bash
mysqldump
```

The generated dump is saved as:

```text
db/application_name.sql
```

The `.sql` extension is used because `mysqldump` produces SQL statements.

---

# 4. Reading the Database Configuration

The task calls:

```ruby
with_config do |app, host, db, user|
```

The helper provides:

```text
app  → Rails application name
host → MySQL host
db   → database name
user → database username
```

These values come from the Rails Active Record database configuration.

For example, a Rails configuration may contain:

```yaml
development:
  adapter: mysql2
  host: localhost
  database: my_app_development
  username: root
```

The Rake task reads these values instead of hard-coding them.

---

# 5. The `with_config` Helper

```ruby
def with_config
  config = ActiveRecord::Base.connection_db_config.configuration_hash

  yield(
    Rails.application.class.parent_name.underscore,
    config[:host] || "localhost",
    config[:database],
    config[:username]
  )
end
```

The helper gets the current Active Record database configuration.

The block:

```ruby
with_config do |app, host, db, user|
  # ...
end
```

receives the configuration values.

Conceptually:

```text
with_config
    │
    ├── application name
    ├── MySQL host
    ├── database name
    └── database username
             │
             ↓
        Rake task block
```

---

# 6. `mysqldump`

MySQL uses:

```bash
mysqldump
```

to create database dumps.

Basic structure:

```bash
mysqldump \
  --host=HOST \
  --user=USER \
  DATABASE
```

The Rake task uses:

```bash
mysqldump --host=HOST --user=USER \
  --single-transaction \
  --routines \
  --triggers \
  DATABASE
```

---

# 7. Important `mysqldump` Options

## `--host`

```bash
--host=HOST
```

Specifies the MySQL server.

For a local database:

```bash
--host=localhost
```

---

## `--user`

```bash
--user=USER
```

Specifies the MySQL username.

For example:

```bash
--user=root
```

---

## `--single-transaction`

```bash
--single-transaction
```

Creates a consistent dump using a transaction for transactional storage engines such as InnoDB.

This is commonly useful when dumping an active development or application database because it can avoid locking tables for the duration of the dump.

---

## `--routines`

```bash
--routines
```

Includes stored procedures and functions in the dump.

---

## `--triggers`

```bash
--triggers
```

Includes database triggers.

Triggers are generally included by default by `mysqldump`, but specifying the option explicitly makes the intention clear.

---

# 8. Redirecting the Dump to a File

The command contains:

```bash
> #{Rails.root}/db/#{app}.sql
```

The `>` shell operator redirects the SQL output into a file.

Conceptually:

```text
MySQL Database
      │
      │ mysqldump
      ↓
   SQL statements
      │
      ↓
db/application_name.sql
```

The resulting file contains SQL that can later be executed against a MySQL database.

---

# 9. `exec cmd`

The task contains:

```ruby
puts cmd
exec cmd
```

First:

```ruby
puts cmd
```

prints the command that is about to be executed.

Then:

```ruby
exec cmd
```

runs the external MySQL command by replacing the current Ruby process.

For the dump task, this command is:

```bash
mysqldump
```

---

# 10. The `db:restore` Task

The restore task uses:

```bash
mysql
```

rather than `mysqldump`.

```ruby
task restore: :environment do
```

The basic process is:

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
     mysql
       │
       ↓
Execute .sql file
       │
       ↓
Restored database
```

---

# 11. Restoring with `mysql`

The restore command looks like:

```bash
mysql \
  --host=HOST \
  --user=USER \
  DATABASE < db/application_name.sql
```

The important difference from PostgreSQL is:

```text
PostgreSQL:
pg_dump → pg_restore

MySQL:
mysqldump → mysql
```

`mysqldump` produces SQL, so the standard `mysql` client can execute that SQL file.

---

# 12. Dropping and Creating the Database

Before restoring:

```ruby
Rake::Task["db:drop"].invoke
Rake::Task["db:create"].invoke
```

The process is:

```text
db:drop
   ↓
Delete existing database

db:create
   ↓
Create empty database

mysql
   ↓
Execute SQL dump

Restored database
```

### ⚠️ Important

`db:drop` is destructive.

It permanently deletes the database configured for the current Rails environment.

Use this task carefully and avoid running it against a database that contains data you need to preserve.

---

# 13. Running the Tasks

## Dump

Run:

```bash
bin/rails db:dump
```

This creates something similar to:

```text
db/application_name.sql
```

---

## Restore

Run:

```bash
bin/rails db:restore
```

This will:

```text
1. Drop the database
2. Create the database
3. Execute the SQL dump
```

---

# 14. What Happens During a Dump?

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
   ├── username
   │
   ↓
Builds mysqldump command
   │
   ↓
Runs mysqldump
   │
   ↓
Creates .sql file
```

---

# 15. What Happens During a Restore?

When you run:

```bash
bin/rails db:restore
```

the process is approximately:

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
Builds mysql command
   │
   ↓
Drops database
   │
   ↓
Creates database
   │
   ↓
Executes SQL dump
   │
   ↓
Database restored
```

---

# 16. PostgreSQL vs MySQL

The biggest difference is the command-line tools.

| Operation           | PostgreSQL   | MySQL       |
| ------------------- | ------------ | ----------- |
| Dump                | `pg_dump`    | `mysqldump` |
| Restore             | `pg_restore` | `mysql`     |
| Typical dump format | Custom / SQL | SQL         |
| Dump extension      | `.dump`      | `.sql`      |
| Rails adapter       | `postgresql` | `mysql2`    |

Conceptually:

```text
PostgreSQL

pg_dump
   ↓
.dump
   ↓
pg_restore
```

```text
MySQL

mysqldump
   ↓
.sql
   ↓
mysql
```

---

# 17. MySQL Passwords

The example intentionally does not put a password directly into the command:

```ruby
cmd = "mysqldump --host=#{host} --user=#{user} ..."
```

You may be prompted for a password depending on your MySQL configuration.

You should generally **avoid putting passwords directly into shell commands**, such as:

```bash
--password=my_password
```

because command-line arguments can potentially be exposed through process inspection or shell history.

For automated environments, consider using appropriate MySQL client configuration, environment variables, or a secure credentials mechanism.

---

# 18. Shell Command Safety

The example constructs a shell command using interpolation:

```ruby
cmd = "mysqldump --host=#{host} --user=#{user} ..."
```

This is convenient, but shell commands should be constructed carefully when configuration values may contain unexpected characters.

For production-quality tooling, consider Ruby's `system` with argument arrays or `Open3`.

For example:

```ruby
system(
  "mysqldump",
  "--host=#{host}",
  "--user=#{user}",
  "--single-transaction",
  "--routines",
  "--triggers",
  db
)
```

For output redirection, you can use Ruby's file handling rather than relying on shell redirection:

```ruby
File.open(Rails.root.join("db", "#{app}.sql"), "w") do |file|
  system(
    "mysqldump",
    "--host=#{host}",
    "--user=#{user}",
    "--single-transaction",
    "--routines",
    "--triggers",
    db,
    out: file
  )
end
```

This avoids using the shell for the `>` redirection.

---

# 19. Database Configuration

A typical Rails MySQL configuration uses the `mysql2` adapter:

```yaml
development:
  adapter: mysql2
  encoding: utf8mb4
  host: localhost
  database: application_development
  username: root
```

The Rake task reads these values through Active Record.

The important relationship is:

```text
config/database.yml
        │
        ↓
   ActiveRecord
        │
        ↓
    with_config
        │
        ├── host
        ├── database
        └── username
        │
        ↓
   mysqldump / mysql
```

---

# 20. Why Use a Database Dump?

Database dumps are useful for:

* Backing up development databases
* Sharing development data
* Reproducing bugs locally
* Moving a database between environments
* Restoring a known database state
* Creating a local copy of a database

For example:

```text
MySQL Database
      │
      │ mysqldump
      ↓
application.sql
      │
      │ mysql
      ↓
Another MySQL Database
```

---

# 21. Security Considerations

Database dumps can contain application data such as:

* User records
* Email addresses
* Application data
* Internal business information
* Authentication-related data
* Other sensitive information

Avoid committing database dumps containing sensitive data to source control.

For example:

```gitignore
# MySQL database dumps
*.sql
```

However, be careful with a broad `*.sql` rule if your repository intentionally contains SQL files such as migrations or seed data.

A more targeted rule may be preferable:

```gitignore
db/*.sql
```

If database dumps need to be shared, use an appropriate secure storage mechanism.

---

# 22. Key Ruby/Rails Concepts Used

This Rake task demonstrates several useful concepts.

### Namespace

```ruby
namespace :db do
```

Groups related Rake tasks.

### Task dependency

```ruby
task dump: :environment
```

Loads the Rails environment before running the task.

### Block

```ruby
with_config do |app, host, db, user|
  # ...
end
```

Receives configuration values from the helper.

### `yield`

```ruby
def with_config
  yield(...)
end
```

Passes values to the supplied block.

### String interpolation

```ruby
"database: #{db}"
```

Inserts Ruby values into a string.

### `exec`

```ruby
exec cmd
```

Runs an external command by replacing the current process.

### Rake task invocation

```ruby
Rake::Task["db:drop"].invoke
```

Runs another Rake task from inside the current task.

---

# 23. Improved Version with MySQL Configuration

A more explicit version can read the database configuration once:

```ruby
namespace :db do

  desc "Dumps the database to db/APP_NAME.sql"
  task dump: :environment do
    config = ActiveRecord::Base.connection_db_config.configuration_hash

    app  = Rails.application.class.parent_name.underscore
    host = config[:host] || "localhost"
    db   = config[:database]
    user = config[:username]

    cmd = "mysqldump --host=#{host} --user=#{user} " \
          "--single-transaction --routines --triggers " \
          "#{db} > #{Rails.root}/db/#{app}.sql"

    puts cmd
    exec cmd
  end

  desc "Restores the database dump at db/APP_NAME.sql"
  task restore: :environment do
    config = ActiveRecord::Base.connection_db_config.configuration_hash

    app  = Rails.application.class.parent_name.underscore
    host = config[:host] || "localhost"
    db   = config[:database]
    user = config[:username]

    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke

    cmd = "mysql --host=#{host} --user=#{user} " \
          "#{db} < #{Rails.root}/db/#{app}.sql"

    puts cmd
    exec cmd
  end

end
```

This version is slightly easier to follow because the database configuration is read directly inside each task.

---

# Quick Reference

```text
File:
lib/tasks/db.rake

Tasks:
bin/rails db:dump
bin/rails db:restore
```

## Dump

```text
Rails configuration
        │
        ↓
    mysqldump
        │
        ↓
db/application_name.sql
```

## Restore

```text
db:drop
    │
    ↓
db:create
    │
    ↓
mysql
    │
    ↓
application.sql
    │
    ↓
Restored database
```

## Core MySQL Commands

```bash
# Create database dump
mysqldump --host=HOST --user=USER DATABASE > database.sql

# Restore SQL dump
mysql --host=HOST --user=USER DATABASE < database.sql
```

---

# Key Takeaway

The Rails Rake task acts as a convenient wrapper around MySQL's command-line tools:

```text
                    Rails
                      │
                      │ ActiveRecord config
                      ↓
                  Rake Task
                 /         \
                ↓           ↓
          mysqldump        mysql
             │                ↑
             ↓                │
        database.sql ─────────┘
```

The main difference from PostgreSQL is:

```text
PostgreSQL:
pg_dump → .dump → pg_restore

MySQL:
mysqldump → .sql → mysql
```

This allows database dump and restore operations to be triggered through familiar Rails commands:

```bash
bin/rails db:dump
bin/rails db:restore
```

> **Important:** The restore task drops and recreates the configured database. Use it only when you are certain the target database can be safely replaced.
