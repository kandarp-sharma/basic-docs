# Deploy Rails Application to Server without Capistrano

A practical guide for deploying a Ruby on Rails application to an Ubuntu server using:

* AWS EC2
* Git
* Nginx
* Ruby via **RVM or rbenv**
* Node.js
* PostgreSQL
* Bundler
* Rails
* systemd
* No Capistrano

> **Note:** RVM and rbenv are alternatives. Choose **one**, not both.

---

# 1. Creating AWS EC2 Instance

Create an EC2 instance from the AWS Console.

Recommended starting configuration:

* Ubuntu Server LTS
* 64-bit architecture
* Suitable instance size for the application
* SSH key pair
* Security group

## Security Group

Allow at least:

| Type  |  Port | Source          |
| ----- | ----: | --------------- |
| SSH   |  `22` | Your IP address |
| HTTP  |  `80` | `0.0.0.0/0`     |
| HTTPS | `443` | `0.0.0.0/0`     |

Avoid exposing PostgreSQL port `5432` publicly unless there is a specific reason.

Connect to the server:

```bash
ssh -i "your-key.pem" ubuntu@YOUR_SERVER_IP
```

Update the system:

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
  nginx \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  libyaml-dev \
  libffi-dev \
  libgmp-dev \
  libpq-dev
```

---

# 2. Installing Git on Server

Check whether Git is installed:

```bash
git --version
```

If it is not installed:

```bash
sudo apt update
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

# 3. Setting Up Git Access

The server needs access to the application's Git repository.

Generate an SSH key:

```bash
ssh-keygen -t ed25519 -C "deployment@example.com"
```

Press Enter to accept the default file location.

Display the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Add this public key to your Git hosting provider as an appropriate deploy/deployment key.

Test the connection according to your Git provider's instructions.

Clone the application:

```bash
cd /var/www

sudo mkdir -p myapp
sudo chown -R $USER:$USER myapp

git clone git@github.com:YOUR_ORGANIZATION/YOUR_REPOSITORY.git myapp
```

Move into the application:

```bash
cd /var/www/myapp
```

---

# 4. Installing Nginx

Install Nginx:

```bash
sudo apt update
sudo apt install -y nginx
```

Check its status:

```bash
sudo systemctl status nginx
```

Enable Nginx at boot:

```bash
sudo systemctl enable nginx
```

Test the server IP in a browser:

```text
http://YOUR_SERVER_IP
```

You should see the default Nginx page.

---

# 5. Installing Ruby

There are two common choices:

* RVM
* rbenv

Choose one.

---

# 5A. Ruby Using RVM

Install GPG:

```bash
sudo apt install -y gnupg2
```

Import the RVM keys according to the current RVM installation instructions.

Then install RVM:

```bash
curl -sSL https://get.rvm.io | bash -s stable
```

Load RVM:

```bash
source ~/.rvm/scripts/rvm
```

Check:

```bash
rvm --version
```

Install the Ruby version required by the application:

```bash
rvm install ruby-X.Y.Z
```

Set the default Ruby:

```bash
rvm use ruby-X.Y.Z --default
```

Verify:

```bash
ruby -v
```

Check Bundler:

```bash
bundle -v
```

If necessary:

```bash
gem install bundler
```

### Using `.ruby-version`

If the application defines a Ruby version through:

```text
.ruby-version
```

use that version rather than installing an arbitrary version.

---

# 5B. Ruby Using rbenv

Install dependencies:

```bash
sudo apt update

sudo apt install -y \
  git \
  curl \
  autoconf \
  bison \
  build-essential \
  libssl-dev \
  libyaml-dev \
  libreadline-dev \
  zlib1g-dev \
  libncurses5-dev \
  libffi-dev \
  libgdbm-dev \
  libdb-dev
```

Install rbenv:

```bash
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-installer | bash
```

Add rbenv to the shell configuration if the installer does not do so automatically.

For Bash:

```bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc
```

Reload:

```bash
source ~/.bashrc
```

Verify:

```bash
rbenv --version
```

Install the Ruby version required by the application:

```bash
rbenv install X.Y.Z
```

Set it as the default:

```bash
rbenv global X.Y.Z
```

Verify:

```bash
ruby -v
```

Install Bundler:

```bash
gem install bundler
```

Verify:

```bash
bundle -v
```

---

# 6. Installing Node.js

Rails applications may require Node.js for JavaScript bundling, asset compilation, or other frontend tooling.

A version manager such as `nvm` is useful when the application requires a specific Node.js version.

Install NVM using the current official installation instructions.

After installation, verify:

```bash
nvm --version
```

Install the required Node.js version:

```bash
nvm install X
```

Use it:

```bash
nvm use X
```

Make it the default:

```bash
nvm alias default X
```

Verify:

```bash
node -v
npm -v
```

> If the application uses Yarn, pnpm, Bun, or another JavaScript package manager, install the version required by the project's lockfile and configuration.

---

# 7. Installing PostgreSQL

Install PostgreSQL:

```bash
sudo apt update
sudo apt install -y postgresql postgresql-contrib libpq-dev
```

Check the service:

```bash
sudo systemctl status postgresql
```

Enable it at boot:

```bash
sudo systemctl enable postgresql
```

---

# 8. Creating the PostgreSQL Database User

Switch to the PostgreSQL administrator:

```bash
sudo -u postgres psql
```

Create a database user:

```sql
CREATE USER app_user WITH PASSWORD 'CHANGE_THIS_PASSWORD';
```

Create the database:

```sql
CREATE DATABASE app_production OWNER app_user;
```

Exit:

```sql
\q
```

Test the connection:

```bash
psql -h localhost -U app_user -d app_production
```

> In production, use a strong secret and avoid putting database passwords directly into source code.

---

# 9. Rails Application Configuration

Go to the application:

```bash
cd /var/www/myapp
```

Check the Ruby version:

```bash
ruby -v
```

Install Ruby dependencies:

```bash
bundle config set --local without 'development test'
bundle install
```

Depending on the application and deployment strategy, you may instead configure Bundler using environment variables or a deployment-specific configuration.

---

# 10. Environment Variables

Production secrets should not be committed to Git.

Typical Rails production variables include:

```bash
export RAILS_ENV=production
export SECRET_KEY_BASE="..."
export DATABASE_URL="postgresql://app_user:PASSWORD@localhost/app_production"
```

Other applications may use:

```bash
export RAILS_MASTER_KEY="..."
```

or another secret-management mechanism.

For a production server, prefer a secure environment-variable or secrets-management solution rather than storing credentials in the repository.

---

# 11. Rails Credentials

If the application uses Rails encrypted credentials, make sure the server has access to the required master key.

For example:

```bash
export RAILS_MASTER_KEY="..."
```

Do **not** commit the master key to Git.

Test Rails:

```bash
RAILS_ENV=production bin/rails runner 'puts Rails.application.class'
```

---

# 12. Database Setup

Run migrations:

```bash
RAILS_ENV=production bin/rails db:migrate
```

If the application requires database creation:

```bash
RAILS_ENV=production bin/rails db:create
```

If required:

```bash
RAILS_ENV=production bin/rails db:seed
```

Be careful with `db:seed` in production because seeds may create or modify real application data.

---

# 13. Assets

The exact command depends on the Rails version and asset pipeline.

Common examples include:

```bash
RAILS_ENV=production bin/rails assets:precompile
```

For applications using modern JavaScript bundlers, the build process may also involve:

```bash
npm install
npm run build
```

or:

```bash
yarn install
yarn build
```

Follow the application's existing build configuration and lockfiles.

---

# 14. Running Rails in Production

A production Rails application should normally run behind a reverse proxy such as Nginx.

One possible application server is Puma.

Check the application's Puma configuration:

```bash
cat config/puma.rb
```

Start Puma manually for testing:

```bash
RAILS_ENV=production bundle exec puma -C config/puma.rb
```

Once confirmed, use `systemd` to manage the process.

---

# 15. Create a systemd Service for Puma

Create:

```bash
sudo nano /etc/systemd/system/myapp.service
```

Example:

```ini
[Unit]
Description=Rails Application
After=network.target postgresql.service

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/var/www/myapp

Environment=RAILS_ENV=production
Environment=RAILS_LOG_TO_STDOUT=true

ExecStart=/home/ubuntu/.rbenv/shims/bundle exec puma -C /var/www/myapp/config/puma.rb

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

> The exact `User`, Ruby path, and `ExecStart` depend on whether you use rbenv, RVM, the server user, and your application setup.

Reload systemd:

```bash
sudo systemctl daemon-reload
```

Enable the application:

```bash
sudo systemctl enable myapp
```

Start it:

```bash
sudo systemctl start myapp
```

Check status:

```bash
sudo systemctl status myapp
```

View logs:

```bash
sudo journalctl -u myapp -f
```

---

# 16. Configure Nginx

Create an Nginx configuration:

```bash
sudo nano /etc/nginx/sites-available/myapp
```

Example:

```nginx
server {
    listen 80;
    server_name example.com www.example.com;

    root /var/www/myapp/public;

    location / {
        proxy_pass http://127.0.0.1:3000;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /assets/ {
        expires 1y;
        add_header Cache-Control public;
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/myapp \
  /etc/nginx/sites-enabled/myapp
```

Remove the default configuration if necessary:

```bash
sudo rm /etc/nginx/sites-enabled/default
```

Test the configuration:

```bash
sudo nginx -t
```

Reload Nginx:

```bash
sudo systemctl reload nginx
```

---

# 17. Deployment Without Capistrano

Without Capistrano, deployment can be a simple sequence of Git and Rails commands.

SSH into the server:

```bash
ssh ubuntu@YOUR_SERVER_IP
```

Go to the application:

```bash
cd /var/www/myapp
```

Get the latest code:

```bash
git fetch origin
git checkout main
git pull --ff-only origin main
```

Install dependencies:

```bash
bundle install
```

Install frontend dependencies if required:

```bash
npm install
```

Run migrations:

```bash
RAILS_ENV=production bin/rails db:migrate
```

Precompile assets:

```bash
RAILS_ENV=production bin/rails assets:precompile
```

Restart Rails:

```bash
sudo systemctl restart myapp
```

Reload Nginx if its configuration changed:

```bash
sudo systemctl reload nginx
```

Check the application:

```bash
sudo systemctl status myapp
```

Check logs:

```bash
sudo journalctl -u myapp -f
```

---

# 18. Simple Manual Deployment Script

Once the deployment process is stable, it can be automated without Capistrano.

Create:

```bash
nano deploy.sh
```

Example:

```bash
#!/usr/bin/env bash

set -e

APP_DIR="/var/www/myapp"

cd "$APP_DIR"

echo "Pulling latest code..."
git pull --ff-only origin main

echo "Installing Ruby dependencies..."
bundle install

echo "Running database migrations..."
RAILS_ENV=production bin/rails db:migrate

echo "Precompiling assets..."
RAILS_ENV=production bin/rails assets:precompile

echo "Restarting application..."
sudo systemctl restart myapp

echo "Deployment completed."
```

Make it executable:

```bash
chmod +x deploy.sh
```

Deploy:

```bash
./deploy.sh
```

---

# 19. Recommended Deployment Flow

The overall flow is:

```text
Developer
    │
    │ git push
    ↓
Git Repository
    │
    │ git pull
    ↓
EC2 Server
    │
    ├── Ruby
    │
    ├── Rails
    │
    ├── PostgreSQL
    │
    └── Puma
          │
          ↓
        Nginx
          │
          ↓
       Internet
```

---

# 20. Deployment Checklist

Before deployment:

```text
[ ] EC2 instance created
[ ] SSH access configured
[ ] Security group configured
[ ] Git installed
[ ] Git repository access configured
[ ] Nginx installed
[ ] Ruby installed
[ ] RVM or rbenv configured
[ ] Correct Ruby version installed
[ ] Bundler installed
[ ] Node.js installed
[ ] Correct Node.js version installed
[ ] PostgreSQL installed
[ ] Production database created
[ ] Production environment variables configured
[ ] Rails credentials configured
[ ] Dependencies installed
[ ] Database migrations run
[ ] Assets compiled
[ ] Puma configured
[ ] systemd service configured
[ ] Nginx configured
[ ] Nginx configuration tested
[ ] Application restarted
[ ] Application logs checked
[ ] Production URL tested
```

---

# 21. Useful Commands

### Check services

```bash
sudo systemctl status nginx
sudo systemctl status postgresql
sudo systemctl status myapp
```

### Restart Rails

```bash
sudo systemctl restart myapp
```

### Restart Nginx

```bash
sudo systemctl restart nginx
```

### Reload Nginx

```bash
sudo systemctl reload nginx
```

### Rails console

```bash
RAILS_ENV=production bin/rails console
```

### Rails routes

```bash
RAILS_ENV=production bin/rails routes
```

### Rails logs

```bash
tail -f log/production.log
```

### Puma/systemd logs

```bash
sudo journalctl -u myapp -f
```

### Nginx logs

```bash
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

---

# 22. Important Production Practices

### Don't commit secrets

Never commit:

```text
.env
credentials
master keys
database passwords
private SSH keys
```

### Use HTTPS

After the HTTP deployment works, configure TLS/HTTPS, commonly using Let's Encrypt and Certbot.

### Use a dedicated deployment user

For production, avoid running the Rails application as `root`.

### Keep the server updated

```bash
sudo apt update
sudo apt upgrade
```

### Monitor logs

Check:

```bash
sudo journalctl -u myapp
```

and:

```bash
/var/log/nginx/
```

### Back up PostgreSQL

A production database should have a tested backup and restore strategy.

---

# Summary

A Rails deployment without Capistrano can be managed with a relatively small set of components:

```text
EC2
 │
 ├── Git
 │
 ├── Ruby
 │    └── RVM OR rbenv
 │
 ├── Node.js
 │
 ├── PostgreSQL
 │
 ├── Rails
 │    └── Puma
 │
 ├── systemd
 │    └── Process management
 │
 └── Nginx
      └── Reverse proxy
```

The basic deployment process is:

```bash
git pull
bundle install
bin/rails db:migrate
bin/rails assets:precompile
sudo systemctl restart myapp
```

Capistrano is therefore **not required**. Git + Bundler + Rails tasks + systemd + Nginx are enough for a straightforward manual deployment setup.
