# Deploy Rails Application to Server usng RVM

A generic guide for deploying a Ruby on Rails application to an Ubuntu-based server using:

* AWS EC2
* Git
* Nginx
* RVM
* Ruby
* Node.js
* MySQL or PostgreSQL
* Capistrano

> **Note:** Commands and package versions may vary depending on the Ubuntu, Ruby, Rails, Node.js, database, and deployment versions being used.

---

# 1. Deployment Architecture

A typical Rails deployment looks like this:

```text
                     Internet
                         │
                         ▼
                    AWS EC2
                         │
                    ┌────┴────┐
                    │  Nginx  │
                    └────┬────┘
                         │
                         ▼
                  Rails Application
                         │
              ┌──────────┴──────────┐
              │                     │
              ▼                     ▼
           Puma                  Database
                              MySQL/PostgreSQL
```

Capistrano handles deploying the Rails application:

```text
Developer Machine
       │
       │ cap production deploy
       ▼
    Server
       │
       ├── Git
       ├── RVM
       ├── Ruby
       ├── Node.js
       ├── Rails
       ├── Puma
       ├── Nginx
       └── Database
```

---

# 2. Creating an AWS EC2 Instance

Create an EC2 instance using the AWS console or infrastructure tooling.

Recommended starting points:

* Choose an Ubuntu Server image.
* Select an appropriate instance size.
* Create or select an SSH key pair.
* Configure the security group.
* Assign a static/Elastic IP if a stable public IP is required.

## Security Group

At minimum, a web application commonly needs:

|  Port | Protocol | Purpose |
| ----: | -------- | ------- |
|  `22` | TCP      | SSH     |
|  `80` | TCP      | HTTP    |
| `443` | TCP      | HTTPS   |

Do **not** expose the database port publicly unless there is a specific reason.

For SSH, restrict access to trusted IP addresses where possible.

---

# 3. Connect to the Server

From your local machine:

```bash
ssh -i /path/to/key.pem ubuntu@SERVER_IP
```

The username depends on the operating system image.

After connecting:

```bash
sudo apt update
sudo apt upgrade -y
```

Install some common utilities:

```bash
sudo apt install -y \
  curl \
  git \
  build-essential \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  libyaml-dev \
  libxml2-dev \
  libxslt1-dev \
  libcurl4-openssl-dev \
  libffi-dev
```

---

# 4. Installing Git

Check whether Git is already installed:

```bash
git --version
```

If it is not installed:

```bash
sudo apt update
sudo apt install -y git
```

Verify:

```bash
git --version
```

Git is required because Capistrano normally retrieves the application source code from a Git repository.

---

# 5. Installing RVM

RVM stands for **Ruby Version Manager**.

It allows you to install and manage Ruby versions on the server.

Install the required GPG keys:

```bash
gpg --keyserver hkps://keyserver.ubuntu.com \
    --recv-keys \
    <RVM_GPG_KEY_1> \
    <RVM_GPG_KEY_2>
```

Install RVM:

```bash
curl -sSL https://get.rvm.io | bash -s stable
```

Load RVM:

```bash
source /etc/profile.d/rvm.sh
```

Verify:

```bash
rvm --version
```

> Use the current official RVM installation instructions and signing keys for production setup.

---

# 6. Installing Ruby

Check the Ruby version required by the application.

For example, if the application requires Ruby `3.x`:

```bash
rvm install 3.x.x
```

Set the default Ruby:

```bash
rvm use 3.x.x --default
```

Verify:

```bash
ruby -v
```

Also check Bundler:

```bash
bundle -v
```

If required:

```bash
gem install bundler
```

The Ruby version on the server should match the version specified by the application.

For example:

```ruby
# Gemfile

ruby "3.x.x"
```

or:

```text
.ruby-version
```

---

# 7. Installing Node.js

Rails applications may require Node.js for JavaScript bundling, asset compilation, or other frontend tooling.

Check whether Node.js is installed:

```bash
node -v
npm -v
```

Install Node.js using a suitable version manager or the Node.js distribution appropriate for the application.

For example, with `nvm`:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/<VERSION>/install.sh | bash
```

Reload the shell:

```bash
source ~/.bashrc
```

Install the required Node.js version:

```bash
nvm install <NODE_VERSION>
nvm use <NODE_VERSION>
nvm alias default <NODE_VERSION>
```

Verify:

```bash
node -v
npm -v
```

Use the Node.js version expected by the application.

---

# 8. Installing Yarn / JavaScript Package Manager

Depending on the Rails application's frontend setup, you may need a JavaScript package manager.

Check the project files:

```bash
ls
```

For example:

```text
package.json
yarn.lock
package-lock.json
```

If the application uses Yarn, install the appropriate version.

Modern Rails applications may instead use npm, pnpm, Bun, or another JavaScript tool.

The deployment environment should match the application's development environment.

---

# 9. Installing MySQL

If the application uses MySQL:

```bash
sudo apt update
sudo apt install -y mysql-server libmysqlclient-dev
```

Check the service:

```bash
sudo systemctl status mysql
```

Enable it at boot:

```bash
sudo systemctl enable mysql
```

Start it if necessary:

```bash
sudo systemctl start mysql
```

Check the MySQL version:

```bash
mysql --version
```

## Create Database

Log in:

```bash
sudo mysql
```

Create a database:

```sql
CREATE DATABASE application_production;
```

Create a database user:

```sql
CREATE USER 'application_user'@'localhost'
IDENTIFIED BY 'STRONG_PASSWORD';
```

Grant permissions:

```sql
GRANT ALL PRIVILEGES
ON application_production.*
TO 'application_user'@'localhost';
```

Apply privileges:

```sql
FLUSH PRIVILEGES;
```

Exit:

```sql
EXIT;
```

> Never commit database passwords to Git.

---

# 10. Installing PostgreSQL

If the application uses PostgreSQL instead of MySQL:

```bash
sudo apt update
sudo apt install -y postgresql postgresql-contrib libpq-dev
```

Check the service:

```bash
sudo systemctl status postgresql
```

Enable it:

```bash
sudo systemctl enable postgresql
```

Create a database user:

```bash
sudo -u postgres createuser -P application_user
```

Create the database:

```bash
sudo -u postgres createdb \
  -O application_user \
  application_production
```

Verify:

```bash
sudo -u postgres psql
```

Then:

```sql
\l
```

Exit:

```sql
\q
```

---

# 11. Configure the Rails Application

Before configuring Capistrano, make sure the Rails application is production-ready.

Important files include:

```text
Gemfile
Gemfile.lock
config/database.yml
config/environments/production.rb
config/routes.rb
```

If using environment variables, production secrets should be supplied securely through the server environment or a secret-management system.

Never commit:

```text
.env
database passwords
API keys
private keys
production credentials
```

---

# 12. Add Capistrano Gems

Add Capistrano to the application's `Gemfile`.

A common setup includes:

```ruby
group :development do
  gem "capistrano"
  gem "capistrano-rails"
  gem "capistrano-rvm"
  gem "capistrano-bundler"
  gem "capistrano3-puma"
end
```

Depending on the application, additional Capistrano plugins may be required.

Then:

```bash
bundle install
```

---

# 13. Initialize Capistrano

Run:

```bash
bundle exec cap install
```

This typically creates:

```text
Capfile
config/
  deploy.rb
  deploy/
    production.rb
    staging.rb
```

A typical structure:

```text
my_app/
├── app/
├── config/
│   ├── deploy.rb
│   └── deploy/
│       ├── production.rb
│       └── staging.rb
├── Capfile
├── Gemfile
└── Gemfile.lock
```

---

# 14. Configure the Capfile

A typical `Capfile` might contain:

```ruby
require "capistrano/setup"
require "capistrano/deploy"

require "capistrano/scm/git"

require "capistrano/bundler"
require "capistrano/rails"
require "capistrano/rvm"
require "capistrano/puma"

Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
```

The exact configuration depends on the versions of Capistrano and its plugins.

---

# 15. Configure `deploy.rb`

Example:

```ruby
# config/deploy.rb

set :application, "my_application"
set :repo_url, "git@github.com:ORGANIZATION/REPOSITORY.git"

set :deploy_to, "/var/www/my_application"

set :rvm_type, :user
set :rvm_ruby_version, "3.x.x"

set :branch, "main"

append :linked_files,
       "config/database.yml",
       "config/master.key"

append :linked_dirs,
       "log",
       "tmp/pids",
       "tmp/cache",
       "tmp/sockets",
       "public/system",
       "public/uploads"
```

The important idea is that Capistrano keeps deployment configuration separate from the application source.

---

# 16. Configure Production Server

Edit:

```text
config/deploy/production.rb
```

Example:

```ruby
server "SERVER_IP",
       user: "DEPLOY_USER",
       roles: %w[app db web],
       primary: true
```

For example, the deployment roles commonly mean:

```text
app → Rails application
web → Nginx / web server
db  → database-related deployment tasks
```

The actual roles depend on your architecture.

---

# 17. SSH Authentication

Capistrano connects to the server using SSH.

Test the connection manually first:

```bash
ssh DEPLOY_USER@SERVER_IP
```

If GitHub or another Git provider is used, the server also needs access to the application's repository.

Test repository access from the server:

```bash
git ls-remote git@github.com:ORGANIZATION/REPOSITORY.git
```

The exact authentication mechanism can be:

* SSH deploy key
* Machine user
* GitHub App
* Other supported Git authentication

Keep credentials and private keys out of the repository.

---

# 18. Configure RVM for Capistrano

The RVM configuration should match the Ruby version installed on the server.

Example:

```ruby
set :rvm_type, :user
set :rvm_ruby_version, "3.x.x"
```

Verify on the server:

```bash
rvm list
```

You should see the Ruby version required by the application.

---

# 19. Configure Puma

Rails applications commonly use **Puma** as the application server.

A typical Puma setup might use:

```text
Nginx
  │
  │ HTTP / Unix socket
  ▼
Puma
  │
  ▼
Rails
```

The Puma configuration may be stored in:

```text
config/puma.rb
```

Example:

```ruby
max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)

threads max_threads_count, max_threads_count

environment ENV.fetch("RAILS_ENV", "production")

bind "unix:///var/www/my_application/shared/tmp/sockets/puma.sock"

pidfile "/var/www/my_application/shared/tmp/pids/puma.pid"

plugin :tmp_restart
```

The exact paths should match the Capistrano deployment directory.

---

# 20. Installing Nginx

Install Nginx:

```bash
sudo apt update
sudo apt install -y nginx
```

Check status:

```bash
sudo systemctl status nginx
```

Enable Nginx:

```bash
sudo systemctl enable nginx
```

Start it:

```bash
sudo systemctl start nginx
```

---

# 21. Configure Nginx

Create a server configuration:

```bash
sudo nano /etc/nginx/sites-available/my_application
```

Example:

```nginx
server {
    listen 80;
    server_name example.com;

    root /var/www/my_application/current/public;

    location / {
        proxy_pass http://unix:/var/www/my_application/shared/tmp/sockets/puma.sock;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location ~ ^/(assets|packs|vite) {
        expires max;
        gzip_static on;
        add_header Cache-Control public;
    }
}
```

The exact configuration depends on the Rails version, asset pipeline, Puma setup, and application architecture.

Enable the site:

```bash
sudo ln -s \
  /etc/nginx/sites-available/my_application \
  /etc/nginx/sites-enabled/my_application
```

Test Nginx:

```bash
sudo nginx -t
```

Reload:

```bash
sudo systemctl reload nginx
```

---

# 22. Deployment Directory

Capistrano commonly uses a directory structure similar to:

```text
/var/www/my_application/
├── current -> releases/20260903120000
├── releases/
│   ├── 20260903120000/
│   └── 20260902110000/
├── repo/
├── revisions.log
└── shared/
    ├── config/
    ├── log/
    ├── tmp/
    └── public/
```

### Important directories

`current`

```text
/var/www/my_application/current
```

Points to the currently deployed release.

`releases`

Contains previous deployments.

`shared`

Contains files/directories that should survive deployments.

For example:

```text
shared/
├── config/
│   ├── database.yml
│   └── master.key
├── log/
├── tmp/
└── public/uploads/
```

---

# 23. First Deployment

Before deploying, verify the Capistrano configuration:

```bash
bundle exec cap production doctor
```

Then deploy:

```bash
bundle exec cap production deploy
```

Capistrano generally performs tasks such as:

```text
Connect to server
       ↓
Fetch Git repository
       ↓
Create release
       ↓
Install Ruby dependencies
       ↓
Compile assets
       ↓
Run migrations
       ↓
Update symlinks
       ↓
Restart application server
       ↓
Point current → new release
```

---

# 24. Database Migration

Capistrano Rails deployments can run migrations during deployment.

Manually, the equivalent is:

```bash
RAILS_ENV=production bundle exec rails db:migrate
```

Check the migration status:

```bash
RAILS_ENV=production bundle exec rails db:migrate:status
```

Be careful with production migrations, especially migrations that:

* Drop columns
* Rename columns
* Change large tables
* Lock tables
* Transform large amounts of data

---

# 25. Rails Production Environment

Common environment variables include:

```text
RAILS_ENV=production
RAILS_MASTER_KEY=...
DATABASE_URL=...
RAILS_LOG_TO_STDOUT=...
```

Do not place real secrets directly into:

```ruby
deploy.rb
```

or:

```text
Git repository
```

Use secure environment configuration or a secrets manager.

---

# 26. Useful Capistrano Commands

### Deploy

```bash
bundle exec cap production deploy
```

### Check deployment configuration

```bash
bundle exec cap production doctor
```

### List Capistrano tasks

```bash
bundle exec cap -T
```

### Run a Rails task

Depending on the installed Capistrano tasks:

```bash
bundle exec cap production rails:console
```

or execute the required task through an appropriate Capistrano task.

### Roll back

```bash
bundle exec cap production deploy:rollback
```

Always verify rollback behavior for the application and database migrations before relying on it in production.

---

# 27. Useful Server Commands

## Check Nginx

```bash
sudo systemctl status nginx
```

Restart:

```bash
sudo systemctl restart nginx
```

Reload:

```bash
sudo systemctl reload nginx
```

Test configuration:

```bash
sudo nginx -t
```

---

## Check Puma

```bash
sudo systemctl status puma
```

Depending on the Capistrano/Puma setup, the service name and management method may differ.

---

## Check Ruby

```bash
ruby -v
```

## Check RVM

```bash
rvm --version
rvm list
```

## Check Node.js

```bash
node -v
npm -v
```

## Check Git

```bash
git --version
```

## Check Database

MySQL:

```bash
mysql --version
```

PostgreSQL:

```bash
psql --version
```

---

# 28. Logs

Rails logs:

```bash
tail -f /var/www/my_application/shared/log/production.log
```

Nginx access log:

```bash
sudo tail -f /var/log/nginx/access.log
```

Nginx error log:

```bash
sudo tail -f /var/log/nginx/error.log
```

For systemd-managed services:

```bash
sudo journalctl -u nginx
```

For Puma, use the appropriate service name:

```bash
sudo journalctl -u puma
```

---

# 29. Common Deployment Problems

## Ruby version mismatch

Check:

```bash
ruby -v
rvm list
```

Compare with:

```text
.ruby-version
```

or:

```ruby
Gemfile
```

---

## Bundler errors

Check:

```bash
bundle -v
```

Then:

```bash
bundle check
```

If dependencies are missing:

```bash
bundle install
```

---

## Git authentication failure

Test:

```bash
git ls-remote git@github.com:ORGANIZATION/REPOSITORY.git
```

Verify the deployment user's SSH configuration and repository access.

---

## Database connection failure

Check:

```bash
RAILS_ENV=production bundle exec rails db:migrate:status
```

Verify:

* Database exists
* Database server is running
* Username is correct
* Password is correct
* Host is correct
* Port is correct
* Rails environment variables are available

---

## Nginx 502 Bad Gateway

A `502` commonly means Nginx cannot communicate with Puma.

Check:

```bash
sudo systemctl status nginx
```

Check Puma:

```bash
sudo systemctl status puma
```

Check whether the socket exists:

```bash
ls -la /var/www/my_application/shared/tmp/sockets/
```

Check logs:

```bash
sudo tail -f /var/log/nginx/error.log
```

---

# 30. Production Deployment Checklist

```text
[ ] EC2 instance created
[ ] Security group configured
[ ] SSH access configured
[ ] Git installed
[ ] RVM installed
[ ] Required Ruby version installed
[ ] Bundler installed
[ ] Node.js installed
[ ] JavaScript package manager configured
[ ] MySQL/PostgreSQL installed
[ ] Production database created
[ ] Database credentials configured securely
[ ] Rails application configured for production
[ ] Capistrano gems installed
[ ] Capfile configured
[ ] deploy.rb configured
[ ] production.rb configured
[ ] Git repository access configured
[ ] Deployment user configured
[ ] Puma configured
[ ] Nginx installed
[ ] Nginx configuration created
[ ] Nginx configuration tested
[ ] First Capistrano deployment completed
[ ] Database migrations completed
[ ] Puma running
[ ] Nginx running
[ ] Rails application accessible
[ ] Logs checked
[ ] HTTPS configured
```

---

# 31. Overall Deployment Flow

```text
1. Create EC2
      ↓
2. Configure SSH / Security Group
      ↓
3. Install Git
      ↓
4. Install RVM
      ↓
5. Install Ruby
      ↓
6. Install Node.js
      ↓
7. Install MySQL / PostgreSQL
      ↓
8. Configure Rails production environment
      ↓
9. Add Capistrano gems
      ↓
10. Configure Capfile
      ↓
11. Configure deploy.rb
      ↓
12. Configure production.rb
      ↓
13. Configure Puma
      ↓
14. Configure Nginx
      ↓
15. Test SSH + Git access
      ↓
16. Run Capistrano deployment
      ↓
17. Run database migrations
      ↓
18. Restart Puma
      ↓
19. Verify Nginx
      ↓
20. Test Rails application
```

---

# Key Concepts

### RVM

Manages Ruby versions on the server.

```text
RVM
 └── Ruby 3.x.x
       └── Rails Application
```

### Capistrano

Automates deployment.

```text
Git → Capistrano → Server → Rails
```

### Puma

Runs the Rails application.

```text
Nginx → Puma → Rails
```

### Nginx

Acts as the public-facing web server/reverse proxy.

```text
Browser → Nginx → Puma → Rails
```

### Database

Stores application data.

```text
Rails → MySQL
```

or:

```text
Rails → PostgreSQL
```

### The Complete Picture

```text
                         Internet
                            │
                            ▼
                       ┌─────────┐
                       │  Nginx  │
                       │  :80/443│
                       └────┬────┘
                            │
                            ▼
                       ┌─────────┐
                       │  Puma   │
                       └────┬────┘
                            │
                            ▼
                     ┌─────────────┐
                     │    Rails    │
                     │ Application │
                     └──────┬──────┘
                            │
                            ▼
                    ┌───────────────┐
                    │ MySQL /       │
                    │ PostgreSQL    │
                    └───────────────┘


Developer
    │
    │ git push
    ▼
Git Repository
    │
    │ Capistrano
    ▼
Production Server
```

> **Important:** This is a generic deployment reference. Before using it in production, verify the exact versions and official installation instructions for the operating system, Ruby/RVM, Rails, Node.js, database, Nginx, Puma, and Capistrano versions in use.
