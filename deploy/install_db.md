# Installing MySQL and PostgreSQL on Ubuntu

This guide covers installing **MySQL** or **PostgreSQL** on an Ubuntu server for local development or application deployment.

> **Note:** The exact package versions and repository configuration depend on the Ubuntu release. Avoid hard-coding an old distribution such as Ubuntu 16.04/Xenial unless maintaining a legacy system.

---

# MySQL

## 1. Update Package Information

```bash
sudo apt update
```

Upgrade existing packages if appropriate:

```bash
sudo apt upgrade -y
```

---

## 2. Install MySQL

Install the MySQL server, client, and development libraries:

```bash
sudo apt install mysql-server mysql-client libmysqlclient-dev
```

The packages provide:

| Package              | Purpose                             |
| -------------------- | ----------------------------------- |
| `mysql-server`       | MySQL database server               |
| `mysql-client`       | MySQL command-line client           |
| `libmysqlclient-dev` | MySQL development libraries/headers |

---

## 3. Check MySQL Status

```bash
sudo systemctl status mysql
```

If necessary:

```bash
sudo systemctl start mysql
```

Enable MySQL to start automatically:

```bash
sudo systemctl enable mysql
```

---

## 4. Connect to MySQL

Depending on the Ubuntu/MySQL configuration:

```bash
sudo mysql
```

Check the version:

```sql
SELECT VERSION();
```

Exit:

```sql
exit;
```

---

## 5. Run MySQL Security Configuration

On installations where it is available:

```bash
sudo mysql_secure_installation
```

Review the prompts carefully.

Typical security considerations include:

```text
Remove anonymous users
Disable remote root login
Remove test database
Reload privilege tables
```

Do not enable or disable options blindly; choose them according to the application's requirements.

---

# PostgreSQL

## 1. Update Package Information

```bash
sudo apt update
```

---

## 2. Install PostgreSQL

For many Ubuntu releases, PostgreSQL is available directly through Ubuntu's package repositories:

```bash
sudo apt install postgresql postgresql-contrib libpq-dev
```

The packages provide:

| Package              | Purpose                                    |
| -------------------- | ------------------------------------------ |
| `postgresql`         | PostgreSQL database server                 |
| `postgresql-contrib` | Additional PostgreSQL extensions/utilities |
| `libpq-dev`          | PostgreSQL client development libraries    |

---

## 3. Check PostgreSQL Status

```bash
sudo systemctl status postgresql
```

Start it if necessary:

```bash
sudo systemctl start postgresql
```

Enable automatic startup:

```bash
sudo systemctl enable postgresql
```

---

# 4. Connect to PostgreSQL

The default administrative PostgreSQL user is commonly:

```text
postgres
```

Connect using:

```bash
sudo -u postgres psql
```

You should see a prompt similar to:

```text
postgres=#
```

Check the PostgreSQL version:

```sql
SELECT version();
```

Exit:

```sql
\q
```

---

# 5. Create a PostgreSQL User

Create a database user:

```bash
sudo -u postgres createuser <username>
```

If the application requires the user to be able to create databases:

```bash
sudo -u postgres createuser --createdb <username>
```

Avoid granting superuser privileges unless they are genuinely required.

### Superuser example

```bash
sudo -u postgres createuser --superuser <username>
```

> **Security:** A PostgreSQL superuser has extensive privileges. Application users should normally use the minimum privileges required.

---

# 6. Set a PostgreSQL Password

Open PostgreSQL:

```bash
sudo -u postgres psql
```

Set a password:

```sql
\password <username>
```

PostgreSQL will prompt for the new password.

Exit:

```sql
\q
```

---

# 7. Create a Database

Create a database owned by the application user:

```bash
sudo -u postgres createdb -O <username> <database_name>
```

For example:

```bash
sudo -u postgres createdb -O app_user app_development
```

---

# 8. Connect to a Database

Using `psql`:

```bash
psql -U <username> -d <database_name>
```

If PostgreSQL is configured for password authentication, it will prompt for the password.

You can also specify the host:

```bash
psql -h localhost -U <username> -d <database_name>
```

---

# 9. Useful PostgreSQL Commands

Once inside `psql`:

### List databases

```sql
\l
```

### List users/roles

```sql
\du
```

### List tables

```sql
\dt
```

### Describe a table

```sql
\d table_name
```

### Exit

```sql
\q
```

---

# MySQL vs PostgreSQL

|                          | MySQL                         | PostgreSQL   |
| ------------------------ | ----------------------------- | ------------ |
| Server package           | `mysql-server`                | `postgresql` |
| Client                   | `mysql-client`                | `psql`       |
| Ruby development library | `libmysqlclient-dev`          | `libpq-dev`  |
| Service                  | `mysql`                       | `postgresql` |
| Default admin user       | Installation/config dependent | `postgres`   |
| Rails adapter            | `mysql2`                      | `pg`         |

For a Rails application, the corresponding database gems are typically:

### MySQL

```ruby
gem "mysql2"
```

### PostgreSQL

```ruby
gem "pg"
```

---

# Rails Database Configuration

For a Rails application using PostgreSQL:

```yaml
development:
  adapter: postgresql
  database: app_development
  username: app_user
  password: <%= ENV["DATABASE_PASSWORD"] %>
  host: localhost
```

For MySQL:

```yaml
development:
  adapter: mysql2
  database: app_development
  username: app_user
  password: <%= ENV["DATABASE_PASSWORD"] %>
  host: localhost
```

> Do not commit production database passwords or other credentials to Git.

---

# Basic Verification

## MySQL

```bash
mysql --version
sudo systemctl status mysql
```

Test the connection:

```bash
sudo mysql -e "SELECT VERSION();"
```

---

## PostgreSQL

```bash
psql --version
sudo systemctl status postgresql
```

Test the connection:

```bash
sudo -u postgres psql -c "SELECT version();"
```

---

# Common Rails Setup

Once the database server and application database user are configured:

```bash
bundle install
bin/rails db:create
bin/rails db:migrate
```

For a fresh development environment:

```bash
bin/rails db:setup
```

Depending on the project, this may create the database, load the schema, and seed development data.

---

# Security Checklist

```text
[ ] Use a supported Ubuntu release
[ ] Use a supported database version
[ ] Keep database packages updated
[ ] Do not expose the database directly to the public internet
[ ] Use a dedicated application database user
[ ] Avoid using database superuser credentials from the application
[ ] Use strong database passwords where password authentication is enabled
[ ] Keep production credentials outside Git
[ ] Restrict database network access
[ ] Enable backups for production databases
[ ] Test database restoration periodically
```

---

# Important: Local vs Production

For local development:

```text
Rails Application
       ↓
localhost
       ↓
MySQL / PostgreSQL
```

For production:

```text
Application Server
       ↓
Private Network
       ↓
Database Server
```

A production database should generally **not** be exposed directly to the public internet.

Instead, restrict database access through:

```text
Private network
Security groups / firewall
VPN
VPC networking
Database-specific authentication
```

---

# Quick Reference

## MySQL

```bash
sudo apt update
sudo apt install mysql-server mysql-client libmysqlclient-dev

sudo systemctl status mysql
sudo mysql
```

## PostgreSQL

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib libpq-dev

sudo systemctl status postgresql
sudo -u postgres psql
```

## PostgreSQL user

```bash
sudo -u postgres createuser <username>
```

## PostgreSQL database

```bash
sudo -u postgres createdb -O <username> <database_name>
```

## PostgreSQL password

```bash
sudo -u postgres psql
```

Then:

```sql
\password <username>
```

---

# Troubleshooting

## Check whether the service is running

MySQL:

```bash
sudo systemctl status mysql
```

PostgreSQL:

```bash
sudo systemctl status postgresql
```

## Restart the service

MySQL:

```bash
sudo systemctl restart mysql
```

PostgreSQL:

```bash
sudo systemctl restart postgresql
```

## Check listening ports

```bash
sudo ss -lntp
```

Common default database ports:

```text
MySQL       → 3306
PostgreSQL  → 5432
```

> A database listening on a port does not mean that port should be publicly accessible. Use firewall/security-group rules to restrict access.

---

# Installation Flow

```text
Ubuntu Server
      ↓
Update packages
      ↓
Install database server
      ↓
Start database service
      ↓
Create application user
      ↓
Create application database
      ↓
Configure authentication
      ↓
Configure Rails
      ↓
Run migrations
      ↓
Test connection
```

> **Principle:** Install the database, create a dedicated application user, grant only the required privileges, keep credentials secure, and verify connectivity before deploying the application.
