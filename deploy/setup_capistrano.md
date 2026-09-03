# Capistrano Deployment Setup for Rails

This guide describes how to configure **Capistrano** for deploying a Ruby on Rails application to staging and production servers.

> Replace all placeholders such as `<application_name>`, `<server_ip>`, `<deploy_user>`, and `<repository_url>` with values appropriate for your environment.

---

## 1. Server Directory Setup

Create the directory where the application will be deployed.

```bash
sudo mkdir -p /var/www
```

Change ownership of `/var/www` to the deployment user:

```bash
sudo chown <deploy_user>:<deploy_user> /var/www
```

Create the application directory:

```bash
cd /var/www

mkdir -p <application_name>/shared/config
```

The resulting structure will look like:

```text
/var/www/
└── <application_name>/
    └── shared/
        └── config/
```

---

## 2. Configure `database.yml`

Create the database configuration file:

```bash
nano /var/www/<application_name>/shared/config/database.yml
```

Add the database configuration required by the Rails application.

Example:

```yaml
production:
  adapter: postgresql
  encoding: unicode
  database: <database_name>
  username: <database_username>
  password: <database_password>
  host: <database_host>
  port: 5432
```

> Keep database credentials secure. Do not commit `database.yml` containing production credentials to Git.

---

# 3. Configure Rails Secrets

The required secret configuration depends on the Rails version.

## Rails 5.2+

Rails 5.2 introduced encrypted credentials using `master.key`.

Create:

```bash
nano /var/www/<application_name>/shared/config/master.key
```

Add the application's `master.key` value:

```text
<RAILS_MASTER_KEY>
```

For example:

```text
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

> Do not commit `master.key` to the repository or expose it publicly.

---

## Older Rails Versions

Depending on the Rails version and application configuration, secrets may be stored in:

```bash
nano /var/www/<application_name>/shared/config/application.yml
```

or:

```bash
nano /var/www/<application_name>/shared/config/secrets.yml
```

For applications using `SECRET_KEY_BASE`, configure:

```yaml
SECRET_KEY_BASE: <SECRET_KEY_BASE>
```

A new secret can be generated when appropriate:

```bash
bundle exec rails secret
```

> Keep production secrets outside source control.

---

# 4. Add Capistrano Gems

Add the required gems to the appropriate group in the `Gemfile`.

```ruby
group :development do
  gem "ed25519", "~> 1.2"
  gem "bcrypt_pbkdf", "~> 1.0"

  gem "capistrano"
  gem "capistrano3-puma"
  gem "capistrano-rails", require: false
  gem "capistrano-bundler", require: false
  gem "capistrano-rvm"
end
```

Install the gems:

```bash
bundle install
```

> Use versions compatible with the Ruby, Rails, Capistrano, and Puma versions used by the application.

---

# 5. Install Capistrano

Run:

```bash
bundle exec cap install
```

This generates the basic Capistrano configuration:

```text
config/
├── deploy.rb
└── deploy/
    ├── production.rb
    └── staging.rb

Capfile
```

---

# 6. Configure the `Capfile`

Open:

```bash
nano Capfile
```

Add the required Capistrano plugins:

```ruby
require "capistrano/bundler"
require "capistrano/rvm"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"
require "capistrano/puma"

install_plugin Capistrano::Puma
```

### Plugin purpose

| Plugin                        | Purpose                          |
| ----------------------------- | -------------------------------- |
| `capistrano/bundler`          | Runs Bundler during deployment   |
| `capistrano/rvm`              | Integrates Capistrano with RVM   |
| `capistrano/rails/assets`     | Handles Rails asset compilation  |
| `capistrano/rails/migrations` | Runs database migrations         |
| `capistrano/puma`             | Manages Puma configuration/tasks |

---

# 7. Configure Puma

After configuring Capistrano and Puma, upload/generate the Puma configuration:

```bash
bundle exec cap production puma:config
```

Depending on your deployment setup, you may need to run the corresponding command for staging as well.

---

# 8. Configure `deploy.rb`

Open:

```bash
nano config/deploy.rb
```

Example configuration:

```ruby
lock "3.11.0"

set :application, "<application_name>"
set :repo_url, "<repository_url>"

# Deployment branch
set :branch, :master

# Deployment directory
set :deploy_to, "/var/www/<application_name>"

set :pty, true

# Files that should exist in the shared/config directory
#
# Rails 5.2+:
set :linked_files, %w[
  config/database.yml
  config/master.key
]

# For older Rails applications using application.yml:
# set :linked_files, %w[
#   config/database.yml
#   config/application.yml
# ]

# Directories shared between releases
set :linked_dirs, %w[
  log
  tmp/pids
  tmp/cache
  tmp/sockets
  vendor/bundle
  public/system
  public/uploads
]

# Number of releases to keep
set :keep_releases, 5
```

---

## Branch Configuration

The deployment branch can be specified explicitly:

```ruby
set :branch, :master
```

Or:

```ruby
set :branch, :main
```

If you want to determine the currently checked-out Git branch:

```bash
git rev-parse --abbrev-ref HEAD
```

You can also configure Capistrano dynamically when appropriate:

```ruby
set :branch, ENV.fetch("BRANCH", "main")
```

Then deploy a specific branch:

```bash
BRANCH=staging bundle exec cap staging deploy
```

---

# 9. Configure Staging

Open:

```bash
nano config/deploy/staging.rb
```

Example:

```ruby
set :rails_env, "staging"
set :puma_env, fetch(:rack_env, fetch(:rails_env, "staging"))

server "<staging_server_ip>", user: "<deploy_user>", roles: %w[web app db]
```

Replace:

```text
<staging_server_ip>
<deploy_user>
```

with the appropriate staging server and deployment user.

---

# 10. Configure Production

Open:

```bash
nano config/deploy/production.rb
```

Example:

```ruby
set :rails_env, "production"
set :puma_env, fetch(:rack_env, fetch(:rails_env, "production"))

server "<production_server_ip>", user: "<deploy_user>", roles: %w[web app db]
```

Replace:

```text
<production_server_ip>
<deploy_user>
```

with the appropriate production server and deployment user.

---

# 11. Deployment Directory Structure

After deployment, Capistrano generally creates a structure similar to:

```text
/var/www/<application_name>/
├── current -> releases/<release>
├── releases/
│   ├── <release_1>/
│   ├── <release_2>/
│   └── ...
└── shared/
    ├── config/
    │   ├── database.yml
    │   └── master.key
    ├── log/
    ├── tmp/
    └── public/
```

`current` points to the currently deployed release.

The `shared` directory contains files and directories that should persist between deployments.

---

# 12. Deploy to Staging

Deploy the application to staging:

```bash
bundle exec cap staging deploy
```

Capistrano will generally:

1. Connect to the server
2. Fetch the Git repository
3. Create a new release
4. Install dependencies
5. Link shared files/directories
6. Compile assets
7. Run database migrations
8. Configure/restart Puma
9. Point `current` to the new release

---

# 13. Deploy to Production

Deploy the application to production:

```bash
bundle exec cap production deploy
```

---

# 14. Restart Nginx

If Nginx needs to be restarted after deployment:

```bash
sudo systemctl restart nginx
```

Check its status:

```bash
sudo systemctl status nginx
```

On systems using the older service command:

```bash
sudo service nginx restart
```

---

# 15. Useful Capistrano Commands

### Check available tasks

```bash
bundle exec cap -T
```

### Deploy staging

```bash
bundle exec cap staging deploy
```

### Deploy production

```bash
bundle exec cap production deploy
```

### Check Puma tasks

```bash
bundle exec cap -T | grep puma
```

### Upload/generate Puma configuration

```bash
bundle exec cap production puma:config
```

### Roll back a deployment

```bash
bundle exec cap production deploy:rollback
```

---

# 16. Important Configuration Files

The main Capistrano files are:

```text
Capfile
config/deploy.rb
config/deploy/staging.rb
config/deploy/production.rb
```

### `Capfile`

Loads Capistrano plugins.

### `deploy.rb`

Contains common deployment configuration.

### `staging.rb`

Contains staging-specific configuration.

### `production.rb`

Contains production-specific configuration.

---

# 17. Shared Files

Files containing environment-specific configuration should generally live under:

```text
shared/config/
```

For example:

```text
shared/
└── config/
    ├── database.yml
    └── master.key
```

Capistrano links these files into every new release.

For example:

```text
current/config/database.yml
    ↓
shared/config/database.yml
```

This prevents sensitive configuration from being lost when a new release is deployed.

---

# 18. Deployment Checklist

Before deploying, verify:

* [ ] Git repository is accessible from the server
* [ ] Deployment user exists
* [ ] SSH authentication is configured
* [ ] Ruby version is installed
* [ ] Bundler is installed
* [ ] RVM/rbenv configuration is correct
* [ ] Database server is accessible
* [ ] `database.yml` exists in `shared/config`
* [ ] Rails secrets are configured
* [ ] `master.key` exists for Rails 5.2+
* [ ] Puma is configured
* [ ] Nginx is configured
* [ ] Required directories have correct permissions
* [ ] Staging server configuration is correct
* [ ] Production server configuration is correct

---

# Quick Deployment Flow

```text
Rails Application
       │
       ↓
     Git
       │
       ↓
   Capistrano
       │
       ├───────────────┐
       ↓               ↓
   Staging         Production
       │               │
       ↓               ↓
     Puma            Puma
       │               │
       └───────┬───────┘
               ↓
             Nginx
               │
               ↓
        Rails Application
```

## Essential Commands

```bash
# Install dependencies
bundle install

# Install Capistrano configuration
bundle exec cap install

# Check Capistrano tasks
bundle exec cap -T

# Deploy staging
bundle exec cap staging deploy

# Deploy production
bundle exec cap production deploy

# Roll back production
bundle exec cap production deploy:rollback

# Restart Nginx
sudo systemctl restart nginx
```

> **Security note:** Never commit production credentials, `master.key`, passwords, private keys, or other secrets to the Git repository. Use the server's `shared` configuration or an appropriate secrets-management system instead.
