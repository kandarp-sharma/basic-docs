# Git Setup for Rails Server Deployment with Capistrano

This guide covers the **Git-related server setup** required for deploying a Rails application with **Capistrano**.

> This document intentionally focuses only on Git and Git-related server configuration.

---

## 1. Installing Git

Install Git on the deployment server:

```bash
sudo apt-get update
sudo apt-get install git
```

Verify the installation:

```bash
git --version
```

Example:

```text
git version 2.x.x
```

---

## 2. Configure Git

Set the Git username:

```bash
git config --global user.name "Deployment Server"
```

Set the Git email:

```bash
git config --global user.email "deployment@example.com"
```

Verify the configuration:

```bash
git config --global --list
```

> The Git username and email are used for Git metadata. They do not need to correspond to a personal identity.

---

## 3. Create an SSH Key for Git

Capistrano typically deploys code by having the server access the Git repository over SSH.

Generate an SSH key:

```bash
ssh-keygen -t ed25519 -C "deployment@example.com"
```

When prompted for the file location, the default is usually appropriate:

```text
~/.ssh/id_ed25519
```

You can protect the key with a passphrase, although automated deployments require additional SSH-agent/key-management considerations if a passphrase is used.

---

## 4. Check the SSH Key

List the generated files:

```bash
ls -la ~/.ssh
```

You should see something similar to:

```text
id_ed25519
id_ed25519.pub
```

The important distinction is:

```text
id_ed25519      → Private key. Keep secret.
id_ed25519.pub  → Public key. Can be added to the Git provider.
```

**Never share or commit the private key.**

---

## 5. Get the Public Key

Display the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Copy the complete output.

It will look similar to:

```text
ssh-ed25519 AAAAC3... deployment@example.com
```

Add this **public key** to the Git repository/provider as the appropriate deployment/deploy key.

---

## 6. Test SSH Access to the Git Provider

Before running Capistrano, verify that the server can authenticate with the Git provider.

For an SSH-based Git repository, test the provider's SSH endpoint.

For example:

```bash
ssh -T git@github.com
```

The first connection may ask you to verify the host fingerprint.

After accepting the fingerprint, you should receive an authentication response from the Git provider.

> The exact command and response depend on the Git hosting provider.

---

## 7. Verify the Repository URL

Check the Git repository URL configured for Capistrano.

An SSH repository URL commonly looks like:

```text
git@github.com:organization/application.git
```

You can test cloning/access without performing a deployment:

```bash
git ls-remote git@github.com:organization/application.git
```

If authentication and repository access are configured correctly, Git will return references such as:

```text
abc123...    HEAD
abc123...    refs/heads/main
```

This is a useful test because it verifies that the server can actually access the repository.

---

## 8. Capistrano Git Configuration

A typical Capistrano deployment configuration contains a repository URL:

```ruby
# config/deploy.rb

set :repo_url, "git@github.com:organization/application.git"
```

The repository URL should use the SSH URL when the deployment server authenticates using an SSH key.

For example:

```ruby
set :repo_url, "git@github.com:organization/application.git"
```

Capistrano will use Git to retrieve the application source during deployment.

---

## 9. Git Branch Configuration

Specify the branch that should be deployed:

```ruby
set :branch, "main"
```

For example:

```ruby
# config/deploy/production.rb

set :branch, "main"
```

This tells Capistrano which Git branch to deploy.

---

## 10. Test Git Access Before Capistrano

Before troubleshooting Capistrano itself, verify Git access directly from the server.

### Check Git

```bash
git --version
```

### Check SSH

```bash
ssh -T git@github.com
```

### Check repository access

```bash
git ls-remote git@github.com:organization/application.git
```

If `git ls-remote` works, the server can authenticate with Git and access the repository.

---

# Troubleshooting

## `Permission denied (publickey)`

Example:

```text
Permission denied (publickey).
fatal: Could not read from remote repository.
```

Check:

```bash
ls -la ~/.ssh
```

Verify that the public key has been added to the Git provider.

Then test:

```bash
ssh -T git@github.com
```

You can also run SSH in verbose mode:

```bash
ssh -vT git@github.com
```

This can help identify which key SSH is attempting to use.

---

## Repository Access Denied

Test the repository directly:

```bash
git ls-remote git@github.com:organization/application.git
```

If authentication succeeds but the repository cannot be accessed, verify that the configured deploy key has access to the correct repository.

---

## Wrong Repository URL

Check the repository URL:

```bash
git ls-remote git@github.com:organization/application.git
```

Make sure the URL in Capistrano matches the repository you intend to deploy:

```ruby
set :repo_url, "git@github.com:organization/application.git"
```

---

# Git Deployment Checklist

Before running Capistrano:

```text
[ ] Git is installed
[ ] Git version can be checked
[ ] SSH key exists
[ ] Public key is registered with the Git provider
[ ] Private key remains protected
[ ] SSH authentication works
[ ] Repository URL is correct
[ ] git ls-remote can access the repository
[ ] Capistrano :repo_url is configured
[ ] Capistrano :branch is configured
```

## Minimal Setup

The essential Git-related setup is:

```bash
# Install Git
sudo apt-get update
sudo apt-get install git

# Generate deployment SSH key
ssh-keygen -t ed25519 -C "deployment@example.com"

# Display public key
cat ~/.ssh/id_ed25519.pub

# Test Git provider authentication
ssh -T git@github.com

# Test repository access
git ls-remote git@github.com:organization/application.git
```

Capistrano configuration:

```ruby
set :repo_url, "git@github.com:organization/application.git"
set :branch, "main"
```

Once `git ls-remote` successfully accesses the repository, the **Git portion of the server setup is ready for Capistrano**.
