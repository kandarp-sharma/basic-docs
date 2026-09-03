# Deploy a Rails Application to a Server using rbenv

This guide describes a typical deployment setup for a **Ruby on Rails application** using:

* AWS EC2
* Ubuntu Linux
* Git
* Nginx
* rbenv
* Ruby
* Node.js
* PostgreSQL or MySQL
* Puma
* Capistrano

> **Note:** Replace placeholders such as `<APP_NAME>`, `<SERVER_IP>`, `<DOMAIN>`, and `<GIT_REPOSITORY>` with values specific to your application.

---

# 1. Deployment Architecture

A typical Rails deployment looks like this:

```text
                    Internet
                       │
                       │ HTTP / HTTPS
                       ▼
                  ┌──────────┐
                  │  Nginx   │
                  └────┬─────┘
                       │
                       │ Proxy
                       ▼
                  ┌──────────┐
                  │   Puma   │
                  └────┬─────┘
                       │
                       ▼
                Rails Application
                       │
              ┌────────┴────────┐
              ▼                 ▼
         PostgreSQL           Redis
          / MySQL           (optional)
```

Capistrano is responsible for deploying the application:

```text
Local Machine
     │
     │ cap production deploy
     ▼
Server
     │
     ├── Git
     ├── rbenv
     ├── Ruby
     ├── Bundler
     ├── Node.js
     ├── Rails
     ├── Puma
     └── Nginx
```

---

# 2. Creating an AWS EC2 Instance

Create an EC2 instance from the AWS Console.

Recommended starting point:

```text
OS:       Ubuntu LTS
CPU:      Depends on application requirements
RAM:      Depends on application requirements
Storage:  Depends on application requirements
```

Choose or create a key pair for SSH access.

## Configure Security Group

At minimum, you typically need:

|  Port | Protocol | Purpose |
| ----: | -------- | ------- |
|  `22` | TCP      | SSH     |
|  `80` | TCP      | HTTP    |
| `443` | TCP      | HTTPS   |

Do **not** expose the database port publicly unless there is a specific requirement.

For example:

```text
SSH
22 → restricted to trusted IP addresses

HTTP
80 → 0.0.0.0/0

HTTPS
443 → 0.0.0.0/0
```

---

# 3. Connect to the Server

From your local machine:

```bash
ssh -i <KEY_FILE>.pem ubuntu@<SERVER_IP>
```

For example:

```bash
ssh -i production-server.pem ubuntu@203.0.113.10
```

The exact username depends on the Linux image being used.

---

# 4. Update the Server

After connecting:

```bash
sudo apt update
sudo apt upgrade -y
```

Install commonly required packages:

```bash
sudo apt install -y \
  build-essential \
  curl \
  git \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  libyaml-dev \
  libxml2-dev \
  libxslt1-dev \
  libffi-dev \
  libgdbm-dev \
  libncurses5-dev \
  autoconf \
  bison \
  rustc
```

---

# 5. Installing Git

Check whether Git is installed:

```bash
git --version
```

If it is not installed:

```bash
sudo apt install -y git
```

Configure Git:

```bash
git config --global user.name "Deployment User"
git config --global user.email "deployment@example.com"
```

Verify:

```bash
git config --global --list
```

---

# 6. Configure Git Access

If the application repository is private, the server needs access to the repository.

Generate an SSH key:

```bash
ssh-keygen -t ed25519 -C "deployment@example.com"
```

Display the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Add the public key to the Git hosting service.

Test the connection according to your Git provider's SSH instructions.

For example:

```bash
ssh -T git@github.com
```

> Never commit private SSH keys, server credentials, or environment secrets to the Rails repository.

---

# 7. Installing Nginx

Install Nginx:

```bash
sudo apt install -y nginx
```

Check the service:

```bash
sudo systemctl status nginx
```

Enable Nginx at boot:

```bash
sudo systemctl enable nginx
```

Start it:

```bash
sudo systemctl start nginx
```

Visit:

```text
http://<SERVER_IP>
```

You should see the default Nginx page.

---

# 8. Installing rbenv

`rbenv` manages Ruby versions on the server.

Install rbenv:

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
```

Add it to the shell:

```bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc
```

Reload the shell:

```bash
source ~/.bashrc
```

Verify:

```bash
rbenv --version
```

---

# 9. Install ruby-build

`ruby-build` allows rbenv to compile and install Ruby versions.

```bash
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
```

Verify available Ruby versions:

```bash
rbenv install -l
```

Install the Ruby version required by the application:

```bash
rbenv install <RUBY_VERSION>
```

For example:

```bash
rbenv install 3.x.x
```

Set the version globally:

```bash
rbenv global <RUBY_VERSION>
```

Verify:

```bash
ruby -v
```

Also verify:

```bash
which ruby
```

It should point to an rbenv-managed Ruby installation.

---

# 10. Install Bundler

Install Bundler:

```bash
gem install bundler
```

Check:

```bash
bundle -v
```

For production deployments, make sure the Bundler version is compatible with the application's `Gemfile.lock`.

---

# 11. Installing Node.js

Rails applications commonly need Node.js for JavaScript tooling or asset compilation.

Use the Node.js version required by the application.

Verify whether Node.js is already installed:

```bash
node -v
npm -v
```

If required, install Node.js using an appropriate version manager or the distribution/package source recommended for the application's Node version.

Verify:

```bash
node --version
npm --version
```

If the application uses Yarn:

```bash
yarn --version
```

Install it if required by the application.

---

# 12. Installing PostgreSQL

Choose **PostgreSQL OR MySQL** according to the application's database configuration.

For PostgreSQL:

```bash
sudo apt install -y postgresql postgresql-contrib libpq-dev
```

Check:

```bash
sudo systemctl status postgresql
```

Enable it:

```bash
sudo systemctl enable postgresql
```

Start it:

```bash
sudo systemctl start postgresql
```

---

## Create PostgreSQL User

Switch to the PostgreSQL administrator:

```bash
sudo -u postgres psql
```

Create a database user:

```sql
CREATE USER <DB_USER> WITH PASSWORD '<DB_PASSWORD>';
```

Create the database:

```sql
CREATE DATABASE <DB_NAME> OWNER <DB_USER>;
```

Exit:

```sql
\q
```

> Prefer managing production credentials through environment variables or a secrets-management solution rather than storing passwords in the repository.

---

# 13. Installing MySQL

If the application uses MySQL instead of PostgreSQL:

```bash
sudo apt install -y mysql-server libmysqlclient-dev
```

Check:

```bash
sudo systemctl status mysql
```

Enable MySQL:

```bash
sudo systemctl enable mysql
```

Start it:

```bash
sudo systemctl start mysql
```

Run the security configuration:

```bash
sudo mysql_secure_installation
```

Create a database:

```bash
sudo mysql
```

Then:

```sql
CREATE DATABASE <DB_NAME>;

CREATE USER '<DB_USER>'@'localhost'
IDENTIFIED BY '<DB_PASSWORD>';

GRANT ALL PRIVILEGES ON <DB_NAME>.* TO '<DB_USER>'@'localhost';

FLUSH PRIVILEGES;
```

Exit:

```sql
EXIT;
```

---

# 14. Configure Rails Database

The Rails application typically uses environment variables.

Example:

```text
DATABASE_NAME=<DB_NAME>
DATABASE_USERNAME=<DB_USER>
DATABASE_PASSWORD=<DB_PASSWORD>
DATABASE_HOST=127.0.0.1
```

The Rails `config/database.yml` can reference them:

```yaml
production:
  adapter: postgresql
  encoding: unicode
  database: <%= ENV.fetch("DATABASE_NAME") %>
  username: <%= ENV.fetch("DATABASE_USERNAME") %>
  password: <%= ENV.fetch("DATABASE_PASSWORD") %>
  host: <%= ENV.fetch("DATABASE_HOST", "127.0.0.1") %>
```

For MySQL, the adapter would typically be:

```yaml
adapter: mysql2
```

---

# 15. Create the Application Directory

A common deployment directory structure is:

```text
/var/www/<APP_NAME>/
```

Create it:

```bash
sudo mkdir -p /var/www/<APP_NAME>
```

Give the deployment user ownership:

```bash
sudo chown -R $USER:$USER /var/www/<APP_NAME>
```

Capistrano will eventually create a structure similar to:

```text
/var/www/<APP_NAME>/
├── current -> releases/<timestamp>
├── releases/
├── repo/
└── shared/
    ├── config/
    ├── log/
    ├── public/
    ├── tmp/
    └── ...
```

---

# 16. Setup Rails Application for Capistrano

Add the required gems to the application's `Gemfile`:

```ruby
group :development do
  gem "capistrano"
  gem "capistrano-rails"
  gem "capistrano-rbenv"
  gem "capistrano3-puma"
end
```

Then:

```bash
bundle install
```

---

# 17. Install Capistrano Files

Run:

```bash
bundle exec cap install
```

This creates files such as:

```text
Capfile
config/deploy.rb
config/deploy/production.rb
```

Depending on the Capistrano setup and installed plugins, additional files/directories may be generated.

---

# 18. Configure `Capfile`

Example:

```ruby
# Load DSL and set up stages
require "capistrano/setup"

# Loads deployment tasks
require "capistrano/deploy"

require "capistrano/scm/git"

require "capistrano/rails"

require "capistrano/rbenv"

require "capistrano/puma"
install_plugin Capistrano::Puma

Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
```

The exact configuration can vary depending on the Capistrano and plugin versions being used.

---

# 19. Configure `config/deploy.rb`

Example:

```ruby
set :application, "<APP_NAME>"
set :repo_url, "<GIT_REPOSITORY>"

set :deploy_to, "/var/www/<APP_NAME>"

set :branch, "main"

set :rbenv_type, :user
set :rbenv_ruby, "<RUBY_VERSION>"

set :linked_files, fetch(:linked_files, []).push(
  "config/master.key"
)

set :linked_dirs, fetch(:linked_dirs, []).push(
  "log",
  "tmp/pids",
  "tmp/cache",
  "tmp/sockets",
  "public/system",
  "public/uploads"
)

set :keep_releases, 5
```

If using Rails credentials, make sure the required credentials file is available securely on the server.

---

# 20. Configure Production Server

Edit:

```text
config/deploy/production.rb
```

Example:

```ruby
server "<SERVER_IP>",
       user: "<DEPLOY_USER>",
       roles: %w[app db web],
       primary: true

set :branch, "main"
```

If using a domain:

```ruby
server "<DOMAIN>",
       user: "<DEPLOY_USER>",
       roles: %w[app db web],
       primary: true
```

---

# 21. SSH Configuration

Test SSH from the local machine:

```bash
ssh <DEPLOY_USER>@<SERVER_IP>
```

Capistrano also needs to be able to connect:

```bash
bundle exec cap production deploy:check
```

If SSH keys are being used, verify:

```bash
ssh -T <DEPLOY_USER>@<SERVER_IP>
```

The exact SSH configuration depends on how the server and deployment credentials are configured.

---

# 22. Configure Puma

Puma runs the Rails application.

A typical Puma configuration may look like:

```ruby
environment ENV.fetch("RAILS_ENV", "production")

threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)

threads threads_count, threads_count

workers ENV.fetch("WEB_CONCURRENCY", 2)

preload_app!

plugin :tmp_restart
```

The exact Puma configuration should be adjusted based on:

* Available CPU
* Available RAM
* Application workload
* Database connection pool
* Puma version

---

# 23. Nginx Configuration

Create an Nginx configuration:

```bash
sudo nano /etc/nginx/sites-available/<APP_NAME>
```

Example:

```nginx
server {
    listen 80;
    server_name <DOMAIN>;

    root /var/www/<APP_NAME>/current/public;

    location / {
        proxy_pass http://127.0.0.1:3000;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location ~ ^/(assets|packs|vite|rails/active_storage) {
        expires max;
        add_header Cache-Control public;
    }
}
```

The exact configuration depends on:

* Puma socket vs TCP
* Rails asset pipeline
* Propshaft
* Sprockets
* Vite
* Active Storage
* Application requirements

---

# 24. Enable Nginx Configuration

Create a symbolic link:

```bash
sudo ln -s \
  /etc/nginx/sites-available/<APP_NAME> \
  /etc/nginx/sites-enabled/<APP_NAME>
```

Test Nginx:

```bash
sudo nginx -t
```

If the configuration is valid:

```bash
sudo systemctl reload nginx
```

---

# 25. First Capistrano Deployment

From your local Rails application:

```bash
bundle exec cap production deploy
```

Capistrano generally performs tasks such as:

```text
Connect to server
       ↓
Clone/update Git repository
       ↓
Create release
       ↓
Install Ruby dependencies
       ↓
Compile assets
       ↓
Run database migrations
       ↓
Create/update symlinks
       ↓
Restart Puma
       ↓
Release application
```

---

# 26. Database Migration

Capistrano Rails deployments commonly run migrations as part of deployment.

You can also run a migration manually if required:

```bash
RAILS_ENV=production bundle exec rails db:migrate
```

After migration:

```bash
RAILS_ENV=production bundle exec rails db:status
```

Be careful when running destructive migrations in production.

---

# 27. Environment Variables

Production configuration should not be committed to Git.

Common variables might include:

```text
RAILS_ENV=production
RAILS_LOG_LEVEL=info

DATABASE_NAME=<DB_NAME>
DATABASE_USERNAME=<DB_USER>
DATABASE_PASSWORD=<DB_PASSWORD>
DATABASE_HOST=127.0.0.1

RAILS_MASTER_KEY=<SECRET>
```

Depending on the application, you may also need:

```text
REDIS_URL=<REDIS_URL>
AWS_ACCESS_KEY_ID=<ACCESS_KEY>
AWS_SECRET_ACCESS_KEY=<SECRET>
MAILER_HOST=<DOMAIN>
```

Use an appropriate secrets-management approach.

Do **not** put production secrets directly into:

```text
Gemfile
Git repository
Capistrano configuration
Nginx configuration
```

---

# 28. Useful Capistrano Commands

Check deployment configuration:

```bash
bundle exec cap production deploy:check
```

Deploy:

```bash
bundle exec cap production deploy
```

Run a task:

```bash
bundle exec cap production <TASK>
```

Check available tasks:

```bash
bundle exec cap -T
```

---

# 29. Useful Server Commands

## Check Nginx

```bash
sudo systemctl status nginx
```

Restart:

```bash
sudo systemctl restart nginx
```

Reload configuration:

```bash
sudo systemctl reload nginx
```

Test configuration:

```bash
sudo nginx -t
```

---

## Check PostgreSQL

```bash
sudo systemctl status postgresql
```

---

## Check MySQL

```bash
sudo systemctl status mysql
```

---

## Check Puma

Depending on the Capistrano/Puma setup:

```bash
sudo systemctl status <APP_NAME>
```

Or inspect the Puma process:

```bash
ps aux | grep puma
```

---

## Check Ruby

```bash
ruby -v
```

```bash
rbenv version
```

```bash
which ruby
```

---

## Check Node.js

```bash
node -v
npm -v
```

---

# 30. Check Application Logs

Rails logs:

```bash
tail -f /var/www/<APP_NAME>/current/log/production.log
```

Nginx access logs:

```bash
sudo tail -f /var/log/nginx/access.log
```

Nginx error logs:

```bash
sudo tail -f /var/log/nginx/error.log
```

Puma logs depend on the Puma/Capistrano configuration.

---

# 31. Deployment Directory

After deployment, Capistrano typically maintains:

```text
/var/www/<APP_NAME>/
│
├── current
│   └── → releases/<latest_release>
│
├── releases/
│   ├── 20260903120000/
│   ├── 20260903130000/
│   └── ...
│
├── repo/
│
└── shared/
    ├── config/
    ├── log/
    ├── tmp/
    └── public/
```

The important concept is:

```text
current
   ↓
latest release
```

This makes it possible for Capistrano to switch releases using a symlink.

---

# 32. Deployment Flow

The complete flow looks like:

```text
Developer
    │
    │ git push
    ▼
Git Repository
    │
    │ cap production deploy
    ▼
Capistrano
    │
    ├── SSH
    │
    ├── Git checkout
    │
    ├── rbenv
    │     └── Ruby
    │
    ├── Bundler
    │
    ├── Rails
    │     ├── Assets
    │     └── Migrations
    │
    └── Puma
          │
          ▼
        Nginx
          │
          ▼
       Internet
```

---

# 33. Common Problems

## Ruby version mismatch

Check:

```bash
ruby -v
rbenv version
```

Make sure the server Ruby version matches the application's expected version.

---

## Bundler errors

Check:

```bash
bundle -v
```

And:

```bash
ruby -v
```

The Bundler version should be compatible with `Gemfile.lock`.

---

## Database connection errors

Check:

```bash
sudo systemctl status postgresql
```

or:

```bash
sudo systemctl status mysql
```

Then verify:

```text
DATABASE_NAME
DATABASE_USERNAME
DATABASE_PASSWORD
DATABASE_HOST
```

---

## Nginx returns `502 Bad Gateway`

Usually check:

```bash
sudo nginx -t
```

Then check whether Puma is running:

```bash
ps aux | grep puma
```

Also verify that Nginx's upstream configuration matches the Puma port or Unix socket.

---

## Rails application does not start

Check:

```bash
tail -f /var/www/<APP_NAME>/current/log/production.log
```

Also verify:

```bash
ruby -v
bundle -v
node -v
```

And check environment variables.

---

# 34. Production Deployment Checklist

Before deploying:

```text
[ ] EC2 instance created
[ ] Security group configured
[ ] SSH access working
[ ] Git installed
[ ] Git repository access configured
[ ] Nginx installed
[ ] rbenv installed
[ ] Required Ruby version installed
[ ] Bundler installed
[ ] Node.js installed
[ ] PostgreSQL/MySQL installed
[ ] Database created
[ ] Database credentials configured
[ ] Capistrano configured
[ ] Puma configured
[ ] Nginx configured
[ ] Production secrets configured
[ ] DNS configured
[ ] HTTPS configured
```

Deploy:

```bash
bundle exec cap production deploy
```

Verify:

```text
[ ] Deployment completed successfully
[ ] Puma is running
[ ] Nginx is running
[ ] Database migrations completed
[ ] Rails application loads
[ ] Assets load correctly
[ ] Logs contain no critical errors
```

---

# 35. Final Architecture

A basic production Rails server can be thought of as:

```text
                         ┌──────────────┐
                         │    Client    │
                         └──────┬───────┘
                                │
                                ▼
                         ┌──────────────┐
                         │    Nginx     │
                         │   Port 80/443│
                         └──────┬───────┘
                                │
                                ▼
                         ┌──────────────┐
                         │     Puma     │
                         │ Rails Server │
                         └──────┬───────┘
                                │
                  ┌─────────────┴─────────────┐
                  ▼                           ▼
           ┌──────────────┐            ┌──────────────┐
           │   Database   │            │    Redis     │
           │ PostgreSQL/  │            │  (optional)  │
           │    MySQL    │            └──────────────┘
           └──────────────┘


Deployment:

Local Machine
      │
      │ Capistrano
      ▼
    Server
      │
      ├── Git
      ├── rbenv
      ├── Ruby
      ├── Bundler
      ├── Node.js
      ├── Rails
      ├── Puma
      └── Nginx
```

## Key Responsibilities

| Component        | Responsibility                          |
| ---------------- | --------------------------------------- |
| AWS EC2          | Provides the server                     |
| Ubuntu           | Server operating system                 |
| Git              | Gets application source code            |
| rbenv            | Manages Ruby versions                   |
| Ruby             | Runs the Rails application              |
| Bundler          | Installs Ruby gems                      |
| Node.js          | Supports JavaScript/build tooling       |
| PostgreSQL/MySQL | Stores application data                 |
| Puma             | Runs Rails                              |
| Nginx            | Handles HTTP/HTTPS and proxies requests |
| Capistrano       | Automates deployments                   |

> **Core idea:** Capistrano deploys the Rails application, rbenv provides the correct Ruby environment, Puma runs Rails, Nginx handles incoming web traffic, and PostgreSQL/MySQL stores the data.
