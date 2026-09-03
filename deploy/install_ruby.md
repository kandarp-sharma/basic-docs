# Installing Ruby for Rails Development

Ruby version managers make it easier to install, switch between, and manage multiple Ruby versions on a development machine.

Common options include:

* [RVM](https://rvm.io/)
* [rbenv](https://github.com/rbenv/rbenv)
* [mise](https://mise.jdx.dev/)

For a Rails project, use the Ruby version required by the application's `.ruby-version`, `Gemfile`, or `Gemfile.lock`.

> **Important:** Avoid installing multiple Ruby version managers in the same shell environment unless there is a specific reason. Choose one approach per development environment.

---

# Option 1: Install Ruby Using RVM

[RVM](https://rvm.io/) can install and manage multiple Ruby versions.

## 1. Install Required Packages

On Debian/Ubuntu-based systems:

```bash
sudo apt-get update

sudo apt-get install -y \
  libgdbm-dev \
  libncurses-dev \
  automake \
  libtool \
  bison \
  libffi-dev
```

The exact package names can vary between Ubuntu/Debian releases.

---

## 2. Install GPG

RVM uses GPG signatures to verify releases.

```bash
sudo apt-get install -y gnupg
```

Import the RVM signing keys using the current instructions from the official RVM documentation.

Then install RVM:

```bash
curl -sSL https://get.rvm.io | bash -s stable
```

Load RVM into the current shell:

```bash
source ~/.rvm/scripts/rvm
```

Verify:

```bash
rvm --version
```

---

## 3. Install Ruby

Replace the example version with the Ruby version required by the Rails application.

```bash
rvm install <ruby-version>
```

For example:

```bash
rvm install 3.3.0
```

Set the default Ruby version:

```bash
rvm use 3.3.0 --default
```

Verify:

```bash
ruby --version
```

---

## 4. Install Bundler

Bundler manages the Ruby gems required by a Rails application.

```bash
gem install bundler
```

Verify:

```bash
bundle --version
```

---

## 5. Install Rails Dependencies

From the Rails application's root directory:

```bash
bundle install
```

If the project specifies a particular Ruby version, verify it before running Bundler:

```bash
ruby --version
bundle --version
```

---

# Option 2: Install Ruby Using rbenv

[rbenv](https://github.com/rbenv/rbenv) provides lightweight Ruby version management and is commonly used for Rails development.

## 1. Install Dependencies

On Debian/Ubuntu:

```bash
sudo apt-get update

sudo apt-get install -y \
  build-essential \
  autoconf \
  bison \
  libssl-dev \
  libyaml-dev \
  libreadline-dev \
  zlib1g-dev \
  libncurses5-dev \
  libffi-dev \
  libgdbm-dev \
  libdb-dev \
  curl \
  git
```

---

## 2. Install rbenv

Clone the repository:

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
```

Add rbenv to the shell:

```bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc
```

Reload the shell:

```bash
exec "$SHELL"
```

Verify:

```bash
rbenv --version
```

---

## 3. Install ruby-build

`ruby-build` provides the Ruby installation functionality used by rbenv.

```bash
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)/plugins/ruby-build"
```

Verify available Ruby versions:

```bash
rbenv install -l
```

---

## 4. Install Ruby

Install the Ruby version required by the Rails application:

```bash
rbenv install <ruby-version>
```

For example:

```bash
rbenv install 3.3.0
```

Set it as the global default:

```bash
rbenv global 3.3.0
```

Verify:

```bash
ruby --version
```

---

## 5. Install Bundler

```bash
gem install bundler
```

Refresh rbenv's shims:

```bash
rbenv rehash
```

Verify:

```bash
bundle --version
```

---

## 6. Configure a Rails Project

rbenv supports a project-specific Ruby version through `.ruby-version`.

From the Rails application directory:

```bash
rbenv local 3.3.0
```

This creates:

```text
.ruby-version
```

Verify:

```bash
ruby --version
```

The project will use the Ruby version specified by `.ruby-version` when working inside that directory.

---

# Option 3: Install Ruby Using mise

[mise](https://mise.jdx.dev/) is a modern runtime version manager that can manage Ruby along with other development tools such as Node.js.

It is useful when a Rails project requires multiple runtimes to be pinned to specific versions.

## 1. Install mise

On Linux:

```bash
curl https://mise.run | sh
```

Follow the shell integration instructions displayed by the installer.

For Bash, this commonly involves adding mise initialization to the shell configuration:

```bash
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
```

Reload the shell:

```bash
exec "$SHELL"
```

Verify:

```bash
mise --version
```

---

## 2. Install Ruby

List available Ruby versions:

```bash
mise ls-remote ruby
```

Install the required version:

```bash
mise use --global ruby@3.3.0
```

Verify:

```bash
ruby --version
```

---

## 3. Configure Ruby Per Rails Project

From the Rails application's root directory:

```bash
mise use ruby@3.3.0
```

mise creates a configuration file such as:

```text
.mise.toml
```

The project can then use the configured Ruby version automatically.

Verify:

```bash
mise current
ruby --version
```

---

## 4. Install Bundler

Once Ruby is configured:

```bash
gem install bundler
```

Verify:

```bash
bundle --version
```

Then install the Rails application's dependencies:

```bash
bundle install
```

---

# Rails Ruby Version Configuration

A Rails project may specify its required Ruby version in multiple places.

## `.ruby-version`

Example:

```text
3.3.0
```

Check it with:

```bash
cat .ruby-version
```

---

## `Gemfile`

A Rails application's `Gemfile` can specify a Ruby version:

```ruby
ruby "3.3.0"
```

Check it with:

```bash
grep '^ruby' Gemfile
```

---

## `Gemfile.lock`

The lockfile can also contain Ruby version information:

```text
RUBY VERSION
   ruby 3.3.0p0
```

Check it with:

```bash
grep -A 2 "RUBY VERSION" Gemfile.lock
```

---

# Installing a Rails Application's Dependencies

After the correct Ruby version is active:

```bash
ruby --version
bundle --version
```

Install the application's gems:

```bash
bundle install
```

Verify the Rails installation:

```bash
bin/rails --version
```

If the application does not have a local Rails executable, use:

```bash
rails --version
```

---

# Comparing Ruby Version Managers

| Feature                       | RVM                 | rbenv   | mise |
| ----------------------------- | ------------------- | ------- | ---- |
| Ruby versions                 | Yes                 | Yes     | Yes  |
| Project-specific versions     | Yes                 | Yes     | Yes  |
| Node.js management            | Limited/not primary | No      | Yes  |
| Multiple runtimes             | No                  | No      | Yes  |
| Lightweight                   | Medium              | Yes     | Yes  |
| Rails-friendly                | Yes                 | Yes     | Yes  |
| Modern multi-runtime workflow | Limited             | Limited | Yes  |

## Which One Should Be Used?

### RVM

Good when:

* An existing project already uses RVM
* Team tooling depends on RVM
* Shell-based Ruby management is preferred

### rbenv

Good when:

* Only Ruby needs to be managed
* A lightweight Ruby version manager is preferred
* The project uses `.ruby-version`

### mise

Good when:

* Ruby and Node.js both need version management
* Multiple runtimes need to be pinned per project
* A modern all-in-one development environment is preferred

---

# Verify the Complete Rails Environment

After installing Ruby, verify the main development tools:

```bash
ruby --version
gem --version
bundle --version
node --version
npm --version
```

Then from the Rails application directory:

```bash
bundle check
bin/rails --version
```

If JavaScript dependencies are used:

```bash
npm install
```

or, for a reproducible installation:

```bash
npm ci
```

---

# Common Troubleshooting

## Wrong Ruby Version

Check:

```bash
ruby --version
cat .ruby-version
```

Also check the `Gemfile`:

```bash
grep '^ruby' Gemfile
```

Make sure the version manager is configured to use the project's required version.

---

## `bundle install` Fails

Check the Ruby and Bundler versions:

```bash
ruby --version
bundle --version
```

Then inspect the application's `Gemfile.lock` for the expected Ruby and Bundler versions.

---

## `ruby: command not found`

Check which version manager is active:

```bash
command -v rvm
command -v rbenv
command -v mise
```

Avoid configuring multiple version managers simultaneously unless required.

---

## Shell Configuration Is Not Loaded

After changing `.bashrc`, reload the shell:

```bash
exec "$SHELL"
```

Then verify:

```bash
ruby --version
```

---

# Best Practices

* Use the Ruby version required by the Rails application.
* Prefer project-specific Ruby versions over relying only on a global version.
* Commit `.ruby-version` when it is part of the project's standard workflow.
* Keep Bundler compatible with the application's `Gemfile.lock`.
* Avoid installing multiple Ruby version managers unnecessarily.
* Keep Ruby and Rails versions within their supported lifecycle.
* Use a version manager rather than replacing the system Ruby.
* Use reproducible dependency installation in CI with `bundle install` according to the project's lockfile and deployment configuration.
* Document required Ruby and Node.js versions for new developers.
* Keep development, CI, and production Ruby versions aligned.

# Quick Reference

## RVM

```bash
rvm install <ruby-version>
rvm use <ruby-version> --default
ruby --version
gem install bundler
bundle install
```

## rbenv

```bash
rbenv install <ruby-version>
rbenv global <ruby-version>
ruby --version
gem install bundler
rbenv rehash
bundle install
```

For a project-specific version:

```bash
rbenv local <ruby-version>
```

## mise

```bash
mise ls-remote ruby
mise use --global ruby@<ruby-version>
ruby --version
gem install bundler
bundle install
```

For a project-specific version:

```bash
mise use ruby@<ruby-version>
```

> **Recommendation:** For a new Rails development environment, `mise` is a strong choice when both Ruby and Node.js need version management. For an existing project, follow the version manager already standardized by the project or team.
