# AWS EC2 Server Setup

A practical guide for creating an AWS EC2 instance, assigning a stable public IP, and preparing a deployment user.

> **Security note:** Avoid exposing SSH (`22`) to `0.0.0.0/0` unless there is a specific reason. Prefer restricting SSH access to a trusted IP address or using AWS Systems Manager where appropriate.

---

# 1. Create an EC2 Instance

## Open AWS Console

1. Log in to the **AWS Management Console**.
2. Open **EC2**.
3. Select **Launch instance**.

---

## Choose an AMI

An **AMI (Amazon Machine Image)** provides the operating system and initial configuration for the instance.

Choose an actively supported Linux distribution.

For example:

```text
Ubuntu Server LTS
```

> Avoid old, unsupported releases such as Ubuntu 16.04.

---

## Choose Instance Type

Select an instance type based on the application's requirements.

Consider:

* CPU
* Memory
* Network performance
* Storage requirements
* Expected traffic
* Cost

For a small development or staging server, a smaller general-purpose instance may be sufficient.

For production, choose the instance size based on measured workload rather than guessing.

---

## Configure Instance Details

Configure the required instance settings.

Depending on the application, you may need to configure:

```text
VPC
Subnet
Auto-assign Public IP
IAM role
Placement
Monitoring
```

Use the default settings when they are appropriate.

---

# 2. Configure Storage

Go to **Configure storage**.

Review:

```text
Volume type
Volume size
IOPS
Encryption
Delete on termination
```

For many general-purpose workloads, an encrypted EBS volume using a general-purpose volume type is a good starting point.

Example:

```text
Root volume
Size:        20 GB
Encryption:  Enabled
```

Choose the size according to application and log-storage requirements.

> Storage requirements should be monitored over time. Running out of disk space can cause serious application and database problems.

---

# 3. Add Tags

Tags help identify and manage AWS resources.

Useful tags include:

```text
Name        → application-server
Environment → production
Application → my-app
Owner       → engineering
```

Example:

```text
Name=application-server
Environment=production
```

Use a consistent tagging convention across AWS resources.

---

# 4. Configure Security Group

A **Security Group** acts as a virtual firewall for the EC2 instance.

Only expose ports that the application actually needs.

Typical rules:

| Type  | Protocol | Port | Source          |
| ----- | -------- | ---: | --------------- |
| SSH   | TCP      |   22 | Trusted IP/CIDR |
| HTTP  | TCP      |   80 | `0.0.0.0/0`     |
| HTTPS | TCP      |  443 | `0.0.0.0/0`     |

For example:

```text
SSH
TCP
22
<TRUSTED-IP>/32
```

Instead of:

```text
SSH
TCP
22
0.0.0.0/0
```

### Why?

This:

```text
0.0.0.0/0
```

means:

> Any IPv4 address on the internet can attempt to connect.

For public web traffic, `80` and `443` are normally expected to be publicly accessible.

SSH is different and should generally be restricted.

---

# 5. Review and Launch

Review:

```text
AMI
Instance type
VPC
Subnet
Public IP configuration
Storage
Security group
Tags
IAM role
```

Then select:

```text
Launch instance
```

---

# 6. SSH Key Pair

AWS uses an SSH key pair for traditional SSH access.

Create or select an existing key pair.

Example:

```text
deployment-key
```

Download the private key securely if creating a new key.

Example:

```text
deployment-key.pem
```

### Important

The private key should:

* Not be committed to Git
* Not be shared
* Not be uploaded to a repository
* Be stored securely
* Have appropriate filesystem permissions

On Linux/macOS:

```bash
chmod 400 deployment-key.pem
```

---

# 7. Find the Instance IP

Open the EC2 instance details.

Find:

```text
Public IPv4 address
```

Example:

```text
203.0.113.10
```

Use the actual address assigned to the instance.

> A normal public IPv4 address may change when an instance is stopped and started. For a stable public IP, use an Elastic IP or another appropriate AWS networking solution.

---

# 8. Connect to the Server

For an Ubuntu instance, the default user is commonly:

```text
ubuntu
```

Connect using:

```bash
ssh -i "/path/to/deployment-key.pem" ubuntu@<PUBLIC_IP>
```

Example:

```bash
ssh -i "~/keys/deployment-key.pem" ubuntu@203.0.113.10
```

The exact default username depends on the AMI.

Common examples include:

```text
Ubuntu       → ubuntu
Amazon Linux → ec2-user
```

---

# 9. Update the Server

Once connected:

```bash
sudo apt update
sudo apt upgrade -y
```

Check the operating system:

```bash
cat /etc/os-release
```

Check the kernel:

```bash
uname -a
```

---

# 10. Create a Deployment User

Avoid using the default cloud user for application deployment.

Create a dedicated user:

```bash
sudo adduser deploy
```

Give it the required administrative privileges:

```bash
sudo usermod -aG sudo deploy
```

Verify:

```bash
groups deploy
```

Expected output should include:

```text
sudo
```

---

# 11. Configure SSH Access for the Deployment User

Switch to the deployment user:

```bash
sudo su - deploy
```

Create the SSH directory if necessary:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

Create the authorized keys file:

```bash
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

---

# 12. Generate an SSH Key

For a deployment user that needs to authenticate with a Git repository, generate an SSH key:

```bash
ssh-keygen -t ed25519
```

When prompted, choose an appropriate key location.

Example:

```text
/home/deploy/.ssh/id_ed25519
```

A passphrase is generally recommended for interactive SSH keys.

For unattended deployment automation, use an appropriate deployment-specific credential strategy rather than blindly creating a passphrase-less personal key.

---

# 13. View the Public Key

Display the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

The output looks similar to:

```text
ssh-ed25519 AAAAC3... deployment@server
```

Only the `.pub` key should be shared.

### Never share:

```text
~/.ssh/id_ed25519
```

The private key must remain secret.

---

# 14. Add the Deployment Key to the Git Repository

If the server needs to clone or pull a private repository, add the **public key** to the repository hosting service as an appropriate:

```text
Deploy key
```

or use another supported machine-to-machine authentication mechanism.

Conceptually:

```text
Server
  │
  │ private key
  ↓
Git provider
  ↑
  │ public key
Repository
```

The server keeps:

```text
id_ed25519       ← PRIVATE
```

The repository receives:

```text
id_ed25519.pub   ← PUBLIC
```

---

# 15. Add an Authorized SSH Key for Server Login

If a trusted administrator needs to SSH into the server as `deploy`, add their **public SSH key** to:

```bash
nano ~/.ssh/authorized_keys
```

Add the public key as a single line.

Then verify permissions:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

---

# 16. Test Git SSH Access

If the deployment user needs access to a private Git repository, test authentication.

For GitHub, for example:

```bash
ssh -T git@github.com
```

For another Git provider, use its documented SSH hostname.

A successful authentication response confirms that the server can authenticate using the configured key.

---

# 17. Test Deployment User

From the server:

```bash
su - deploy
```

Check:

```bash
whoami
```

Expected:

```text
deploy
```

Check sudo access:

```bash
sudo -v
```

---

# 18. Recommended Server Structure

A simple application server can use a structure such as:

```text
/home/deploy/
├── .ssh/
│   ├── authorized_keys
│   ├── id_ed25519
│   └── id_ed25519.pub
│
└── apps/
    └── my-app/
```

Create the application directory:

```bash
mkdir -p ~/apps
```

---

# 19. Security Checklist

Before putting the server into production:

```text
[ ] Supported OS release
[ ] Supported Ruby/runtime version
[ ] SSH restricted to trusted sources
[ ] Private SSH keys protected
[ ] No private keys committed to Git
[ ] Only required ports exposed
[ ] EBS storage encrypted
[ ] IAM permissions follow least privilege
[ ] Deployment user created
[ ] Production secrets stored securely
[ ] Server updates maintained
[ ] Logging enabled
[ ] Monitoring configured
[ ] Backups configured where required
[ ] Recovery procedure documented
```

---

# 20. Network Flow

A typical web server setup looks like:

```text
                    Internet
                       │
                       ↓
              ┌─────────────────┐
              │ AWS Security     │
              │ Group            │
              └────────┬────────┘
                       │
              ┌────────┴────────┐
              │                 │
           HTTPS 443          SSH 22
              │                 │
              ↓                 ↓
       ┌────────────────────────────┐
       │          EC2 Instance      │
       │                            │
       │  Web Server / Application  │
       │                            │
       └────────────────────────────┘
```

For production applications, the architecture may instead use:

```text
Internet
   ↓
Load Balancer
   ↓
EC2 / Auto Scaling
   ↓
Database
```

---

# 21. Elastic IP

An **Elastic IP** provides a static public IPv4 address that can be associated with an AWS resource.

Use it when a stable public IPv4 address is genuinely required.

In the AWS Console:

```text
EC2
  ↓
Network & Security
  ↓
Elastic IPs
  ↓
Allocate Elastic IP address
```

After allocation:

```text
Select Elastic IP
  ↓
Actions
  ↓
Associate Elastic IP address
  ↓
Select resource
  ↓
Select EC2 instance
  ↓
Associate
```

The instance will then use the associated Elastic IP.

---

# 22. Important Elastic IP Considerations

An Elastic IP is not automatically better than every alternative.

Before using one, consider whether the application should instead use:

```text
DNS
Load Balancer
Auto Scaling
Private networking
AWS Systems Manager
```

For a production web application, DNS is generally preferable for users:

```text
example.com
     ↓
DNS
     ↓
Load Balancer / Server
```

Users should generally not need to know the server's IP address.

---

# 23. Basic EC2 Setup Summary

```text
Create EC2 Instance
        ↓
Choose supported AMI
        ↓
Choose instance type
        ↓
Configure storage
        ↓
Add tags
        ↓
Configure Security Group
        ↓
Create/select SSH key pair
        ↓
Launch instance
        ↓
Connect via SSH
        ↓
Update server
        ↓
Create deploy user
        ↓
Configure SSH
        ↓
Configure Git access
        ↓
Deploy application
```

---

# 24. Minimal Command Reference

## Connect

```bash
ssh -i "/path/to/key.pem" ubuntu@<PUBLIC_IP>
```

## Update Ubuntu

```bash
sudo apt update
sudo apt upgrade -y
```

## Create deployment user

```bash
sudo adduser deploy
sudo usermod -aG sudo deploy
```

## Switch user

```bash
sudo su - deploy
```

## Create SSH directory

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

## Generate an SSH key

```bash
ssh-keygen -t ed25519
```

## Display public key

```bash
cat ~/.ssh/id_ed25519.pub
```

## Configure authorized keys

```bash
nano ~/.ssh/authorized_keys
```

## Fix SSH permissions

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

---

# 25. Final Principle

An EC2 setup should not just be:

```text
Create server
→ Open ports
→ SSH
→ Deploy
```

A better production mindset is:

```text
Provision
   ↓
Secure
   ↓
Restrict access
   ↓
Configure identity
   ↓
Deploy
   ↓
Monitor
   ↓
Backup
   ↓
Maintain
```

> **Start with the minimum access required, keep credentials private, expose only necessary network ports, and avoid treating a single EC2 instance as the entire production architecture.**
