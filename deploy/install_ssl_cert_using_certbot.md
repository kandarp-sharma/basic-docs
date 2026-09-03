# Install SSL Certificate with Let's Encrypt and Certbot

[Let's Encrypt](https://letsencrypt.org/) provides free TLS/SSL certificates, while [Certbot](https://certbot.eff.org/) automates certificate issuance and renewal.

This guide assumes:

* Ubuntu/Debian-based Linux
* Nginx is installed and running
* The domain points to the server
* HTTP traffic on port `80` and HTTPS traffic on port `443` can reach the server
* The application is already configured to run behind Nginx

Replace the example domain with the actual domain used by the application.

---

# 1. Install Certbot

If an older APT-managed Certbot installation exists, remove it before installing the Snap version:

```bash
sudo apt remove certbot
```

Install Certbot using Snap:

```bash
sudo snap install --classic certbot
```

Make the Certbot command available system-wide:

```bash
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

Verify the installation:

```bash
certbot --version
```

---

# 2. Test the Configuration with Staging

Before requesting a production certificate, use the Let's Encrypt staging environment.

The staging environment is useful for testing because it does not issue a trusted production certificate and helps avoid production rate limits.

Run:

```bash
sudo certbot --nginx \
  --staging \
  -d example.com \
  -d www.example.com
```

Certbot will:

1. Validate domain ownership.
2. Communicate with Let's Encrypt.
3. Obtain a staging certificate.
4. Update the Nginx configuration when using the `--nginx` plugin.
5. Configure HTTPS for the specified domains.

> **Important:** A staging certificate is not trusted by normal browsers. It is only intended for testing.

---

# 3. Request the Production Certificate

Once the Nginx configuration and domain setup have been tested successfully, request the production certificate:

```bash
sudo certbot --nginx \
  -d example.com \
  -d www.example.com
```

Certbot can automatically update the Nginx configuration to enable HTTPS.

During the process, Certbot may ask whether HTTP requests should be redirected to HTTPS.

For most production Rails applications, redirecting HTTP to HTTPS is recommended.

---

# 4. Manual Nginx Configuration

If Certbot should obtain the certificate without automatically modifying Nginx configuration files, use `certonly`.

```bash
sudo certbot certonly \
  --nginx \
  -d example.com \
  -d www.example.com
```

With `certonly`:

* Certbot obtains the certificate.
* Certbot performs the domain validation.
* Nginx configuration is not automatically modified.
* The administrator is responsible for configuring Nginx to use the certificate.

Certificates are normally stored under:

```text
/etc/letsencrypt/live/example.com/
```

Typical files include:

```text
fullchain.pem
privkey.pem
```

---

# 5. Configure Nginx Manually

A typical HTTPS Nginx server block for a Rails application looks like:

```nginx
server {
    listen 443 ssl http2;
    server_name example.com www.example.com;

    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

    root /var/www/example/current/public;

    location / {
        try_files $uri $uri/index.html $uri @rails;
    }

    location @rails {
        proxy_pass http://127.0.0.1:3000;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

The exact Nginx configuration depends on the Rails deployment architecture.

---

# 6. Redirect HTTP to HTTPS

A separate HTTP server block can redirect traffic to HTTPS:

```nginx
server {
    listen 80;
    server_name example.com www.example.com;

    return 301 https://$host$request_uri;
}
```

Test the Nginx configuration:

```bash
sudo nginx -t
```

If the configuration is valid, reload Nginx:

```bash
sudo systemctl reload nginx
```

---

# 7. Verify the Certificate

Check the certificates managed by Certbot:

```bash
sudo certbot certificates
```

Inspect the certificate:

```bash
sudo openssl x509 \
  -in /etc/letsencrypt/live/example.com/fullchain.pem \
  -noout \
  -dates
```

Check the HTTPS endpoint:

```bash
curl -I https://example.com
```

A successful HTTPS request should return an HTTP response from the application or Nginx.

---

# 8. Test Certificate Renewal

Let's Encrypt certificates have a limited validity period, so automatic renewal is important.

Run a renewal simulation:

```bash
sudo certbot renew --dry-run
```

A successful dry run indicates that the renewal configuration is working.

Check Certbot's systemd timers:

```bash
systemctl list-timers | grep certbot
```

Depending on the installation, Certbot may use a systemd timer or another automated mechanism to perform renewals.

---

# 9. Renew Certificates

Normally, Certbot handles renewal automatically.

To manually trigger the renewal process:

```bash
sudo certbot renew
```

Only certificates that are eligible for renewal will normally be renewed.

After renewal, verify the certificate:

```bash
sudo certbot certificates
```

---

# 10. Nginx Reload After Renewal

If Nginx needs to be reloaded after certificate renewal, Certbot can use a deploy hook.

Example:

```bash
sudo certbot renew \
  --deploy-hook "systemctl reload nginx"
```

This reloads Nginx only after a certificate has successfully been renewed.

---

# 11. Rails Configuration

When Rails runs behind Nginx, make sure the application understands that the original request uses HTTPS.

A typical production configuration may include:

```ruby
# config/environments/production.rb

config.force_ssl = true
```

This enables Rails HTTPS-related behavior such as:

* Redirecting HTTP requests to HTTPS
* Secure cookies
* HSTS-related behavior
* URL generation using HTTPS

The exact configuration should match the application's deployment architecture.

---

# 12. Reverse Proxy Headers

When Nginx terminates TLS and proxies requests to Rails, forward the original protocol:

```nginx
proxy_set_header X-Forwarded-Proto $scheme;
```

Also forward the original host:

```nginx
proxy_set_header Host $host;
```

And client information:

```nginx
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

These headers allow Rails and other application components to correctly determine the original request information.

---

# 13. Firewall Configuration

HTTPS requires port `443` to be reachable.

If UFW is being used:

```bash
sudo ufw allow 'Nginx Full'
```

Check the firewall:

```bash
sudo ufw status
```

The server should allow:

```text
80/tcp   HTTP
443/tcp  HTTPS
```

Avoid exposing unnecessary services or ports to the public internet.

---

# 14. Troubleshooting

## Certbot Cannot Validate the Domain

Verify DNS:

```bash
dig example.com
dig www.example.com
```

The domain should resolve to the server running Nginx.

Also verify that port `80` is accessible.

---

## Nginx Configuration Test Fails

Run:

```bash
sudo nginx -t
```

Inspect the error carefully.

After correcting the configuration:

```bash
sudo systemctl reload nginx
```

---

## Certificate Is Not Trusted

If a staging certificate was installed, browsers will report it as untrusted.

Remove the staging certificate/configuration and request a production certificate:

```bash
sudo certbot --nginx \
  -d example.com \
  -d www.example.com
```

---

## HTTPS Works but Rails Generates HTTP URLs

Check that Nginx forwards the protocol:

```nginx
proxy_set_header X-Forwarded-Proto $scheme;
```

Also verify the Rails production configuration:

```ruby
config.force_ssl = true
```

---

## Renewal Test Fails

Run:

```bash
sudo certbot renew --dry-run
```

Then inspect the Certbot logs:

```bash
sudo journalctl -u certbot
```

or:

```bash
sudo ls -la /var/log/letsencrypt/
```

Check:

* DNS configuration
* Nginx configuration
* Firewall rules
* Port `80` accessibility
* Port `443` accessibility
* Certificate paths
* Certbot renewal configuration

---

# 15. Security Checklist

* [ ] Domain DNS points to the correct server
* [ ] Nginx is configured correctly
* [ ] Port `80` is available for HTTP/ACME validation
* [ ] Port `443` is available for HTTPS
* [ ] Production certificates are used instead of staging certificates
* [ ] HTTP redirects to HTTPS
* [ ] Rails HTTPS configuration is enabled where appropriate
* [ ] `X-Forwarded-Proto` is forwarded correctly
* [ ] Certificate renewal has been tested
* [ ] Private keys are not committed to Git
* [ ] `/etc/letsencrypt` permissions are not unnecessarily weakened
* [ ] Only required firewall ports are exposed

---

# Quick Reference

## Install Certbot

```bash
sudo apt remove certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

## Verify Certbot

```bash
certbot --version
```

## Test with Staging

```bash
sudo certbot --nginx \
  --staging \
  -d example.com \
  -d www.example.com
```

## Production Certificate

```bash
sudo certbot --nginx \
  -d example.com \
  -d www.example.com
```

## Manual Configuration

```bash
sudo certbot certonly \
  --nginx \
  -d example.com \
  -d www.example.com
```

## List Certificates

```bash
sudo certbot certificates
```

## Test Renewal

```bash
sudo certbot renew --dry-run
```

## Renew Certificates

```bash
sudo certbot renew
```

## Test Nginx

```bash
sudo nginx -t
```

## Reload Nginx

```bash
sudo systemctl reload nginx
```

---

# Recommended Production Flow

```text
Domain DNS
    |
    v
Nginx :80
    |
    +---- Let's Encrypt ACME validation
    |
    v
Certbot
    |
    v
TLS Certificate
    |
    v
Nginx :443
    |
    v
Rails Application
```

A typical setup is:

1. Configure DNS.
2. Configure Nginx for the domain.
3. Verify HTTP access.
4. Install Certbot.
5. Test using the staging environment.
6. Request the production certificate.
7. Enable HTTP → HTTPS redirection.
8. Configure Rails for HTTPS.
9. Test HTTPS.
10. Run `certbot renew --dry-run`.
11. Monitor certificate renewal.
