# Nginx + Puma Configuration for Ruby on Rails

This guide configures **Nginx** as a reverse proxy in front of a Ruby on Rails application running with **Puma**.

The general architecture is:

```text
Client
  |
  | HTTP :80
  v
Nginx
  |
  | Unix Socket
  v
Puma
  |
  v
Rails Application
```

Nginx is responsible for:

* Accepting HTTP requests
* Serving static assets
* Forwarding dynamic requests to Puma
* Setting proxy headers
* Handling error pages
* Configuring request/body limits
* Managing connection behavior

---

# 1. Install Nginx

On Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install nginx
```

Check the installation:

```bash
nginx -v
```

Check the service:

```bash
sudo systemctl status nginx
```

---

# 2. Nginx Configuration Locations

Common Nginx configuration directories:

```text
/etc/nginx/
├── nginx.conf
├── sites-available/
└── sites-enabled/
```

Typically:

```text
sites-available/
    ↓
Contains available site configurations

sites-enabled/
    ↓
Contains enabled site configurations
```

A common pattern is to create the application configuration in:

```text
/etc/nginx/sites-available/<application_name>
```

and enable it with a symbolic link:

```text
/etc/nginx/sites-enabled/<application_name>
```

---

# 3. Create an Application Configuration

Create a configuration file:

```bash
sudo nano /etc/nginx/sites-available/<application_name>
```

Example:

```nginx
upstream app {
  server unix:/home/<deploy_user>/<application_name>/shared/tmp/sockets/puma.sock fail_timeout=0;
}

server {
  listen 80;
  server_name <domain_or_ip>;

  root /home/<deploy_user>/<application_name>/current/public;

  try_files $uri/index.html $uri @app;

  location / {
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header Host $host;

    proxy_redirect off;
    proxy_http_version 1.1;
    proxy_set_header Connection '';

    proxy_pass http://app;
  }

  location ~ ^/(assets|fonts|system)/|favicon.ico|robots.txt {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  error_page 500 502 503 504 /500.html;

  client_max_body_size 10M;
  keepalive_timeout 10;
}
```

Replace:

```text
<deploy_user>
<application_name>
<domain_or_ip>
```

with the appropriate values for the deployment.

---

# 4. Understanding the `upstream` Block

```nginx
upstream app {
  server unix:/home/<deploy_user>/<application_name>/shared/tmp/sockets/puma.sock fail_timeout=0;
}
```

The `upstream` block defines the backend application server.

In this setup, Nginx communicates with Puma through a **Unix socket**:

```text
Nginx
  |
  | /shared/tmp/sockets/puma.sock
  v
Puma
```

The socket path must match the socket configured for Puma.

For example:

```text
<application_root>/shared/tmp/sockets/puma.sock
```

If Nginx cannot find the socket, requests will typically result in a `502 Bad Gateway`.

---

# 5. Server Block

```nginx
server {
  listen 80;
  server_name <domain_or_ip>;

  root /home/<deploy_user>/<application_name>/current/public;
}
```

### `listen`

```nginx
listen 80;
```

Nginx listens for HTTP traffic on port `80`.

For HTTPS, a separate configuration normally listens on port `443`.

### `server_name`

```nginx
server_name <domain_or_ip>;
```

Set this to the application's domain:

```nginx
server_name example.com www.example.com;
```

For a temporary/local configuration, an IP address or appropriate hostname can be used.

### `root`

```nginx
root /home/<deploy_user>/<application_name>/current/public;
```

Rails serves public/static files from:

```text
current/public
```

The `current` directory is commonly used by deployment tools such as Capistrano.

---

# 6. `try_files`

```nginx
try_files $uri/index.html $uri @app;
```

This tells Nginx:

```text
1. Look for $uri/index.html
        ↓
2. Look for $uri
        ↓
3. If not found, send the request to @app
```

The `@app` location is an internal Nginx route that forwards the request to Puma.

This allows Nginx to serve static files directly while forwarding Rails requests to Puma.

---

# 7. Proxy Configuration

```nginx
location / {
  proxy_set_header X-Forwarded-Proto $scheme;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header Host $host;

  proxy_redirect off;
  proxy_http_version 1.1;
  proxy_set_header Connection '';

  proxy_pass http://app;
}
```

This block forwards application requests to Puma.

---

## Forwarded protocol

```nginx
proxy_set_header X-Forwarded-Proto $scheme;
```

Passes the original protocol to Rails:

```text
http
https
```

This is important when Rails needs to know whether the original request was HTTP or HTTPS.

---

## Forwarded IP

```nginx
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

Preserves the client's IP information through the proxy chain.

---

## Real client IP

```nginx
proxy_set_header X-Real-IP $remote_addr;
```

Passes the connecting client's IP address to the application.

---

## Host

```nginx
proxy_set_header Host $host;
```

Preserves the original hostname.

This can be important for:

* URL generation
* Rails host authorization
* Multi-domain applications
* Application-level routing

---

# 8. Static Assets

Example:

```nginx
location ~ ^/(assets|fonts|system)/|favicon.ico|robots.txt {
  gzip_static on;
  expires max;
  add_header Cache-Control public;
}
```

This allows Nginx to serve common static resources directly instead of sending them through Rails.

Examples:

```text
/assets/
/fonts/
/system/
/favicon.ico
/robots.txt
```

This reduces work for Puma and Rails.

---

# 9. Error Pages

```nginx
error_page 500 502 503 504 /500.html;
```

This tells Nginx which page to serve for certain server-side errors.

Rails applications commonly have:

```text
public/500.html
```

Make sure the referenced file actually exists.

---

# 10. Request Body Size

```nginx
client_max_body_size 10M;
```

This limits the maximum size of the request body.

For applications handling file uploads, adjust this according to the application's requirements.

For example:

```nginx
client_max_body_size 50M;
```

Avoid setting an unnecessarily large limit.

---

# 11. Keepalive

```nginx
keepalive_timeout 10;
```

Controls how long an idle keep-alive connection remains open.

The appropriate value depends on the application's traffic and infrastructure.

---

# 12. Enable the Site

Remove the default site if it is no longer needed:

```bash
sudo rm /etc/nginx/sites-enabled/default
```

Create a symbolic link:

```bash
sudo ln -nfs \
  "/etc/nginx/sites-available/<application_name>" \
  "/etc/nginx/sites-enabled/<application_name>"
```

You can verify the link:

```bash
ls -la /etc/nginx/sites-enabled/
```

---

# 13. Test the Nginx Configuration

**Always test the configuration before restarting Nginx.**

```bash
sudo nginx -t
```

Expected output should indicate that the configuration syntax is valid.

If there is an error, fix it before continuing.

You can also inspect the complete configuration:

```bash
sudo nginx -T
```

---

# 14. Reload Nginx

After a successful configuration test:

```bash
sudo systemctl reload nginx
```

Check the service:

```bash
sudo systemctl status nginx
```

If Nginx is not running:

```bash
sudo systemctl start nginx
```

Enable it to start automatically:

```bash
sudo systemctl enable nginx
```

---

# 15. Puma Socket

The Nginx configuration depends on Puma exposing a Unix socket.

Example:

```text
/home/<deploy_user>/<application_name>/shared/tmp/sockets/puma.sock
```

Check whether the socket exists:

```bash
ls -la /home/<deploy_user>/<application_name>/shared/tmp/sockets/
```

You should see something similar to:

```text
puma.sock
```

If the socket does not exist, investigate Puma before troubleshooting Nginx.

---

# 16. Application Directory Structure

A deployment using a `current` release and `shared` directory might look like:

```text
/home/<deploy_user>/<application_name>/
│
├── current/
│   ├── app/
│   ├── config/
│   ├── public/
│   └── ...
│
└── shared/
    ├── log/
    ├── tmp/
    │   └── sockets/
    │       └── puma.sock
    └── ...
```

The important relationship is:

```text
Nginx
  |
  +── current/public
  |
  +── shared/tmp/sockets/puma.sock
```

---

# 17. Alternative Configuration Style

Instead of sending requests directly through:

```nginx
location / {
  proxy_pass http://app;
}
```

you can define a named location:

```nginx
upstream puma {
  server unix:///home/<deploy_user>/<application_name>/shared/tmp/sockets/puma.sock;
}

server {
  listen 80;
  server_name <domain_or_ip>;

  root /home/<deploy_user>/<application_name>/current/public;

  access_log /home/<deploy_user>/<application_name>/current/log/nginx.access.log;
  error_log /home/<deploy_user>/<application_name>/current/log/nginx.error.log info;

  location ^~ /assets/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  try_files $uri/index.html $uri @puma;

  location @puma {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header Host $http_host;

    proxy_redirect off;

    proxy_pass http://puma;
  }

  error_page 500 502 503 504 /500.html;

  client_max_body_size 10M;
  keepalive_timeout 10;
}
```

The two approaches serve the same basic purpose:

```text
Nginx
  ↓
Puma Unix Socket
  ↓
Rails
```

The exact configuration should be chosen based on the deployment setup.

---

# 18. Troubleshooting

## Nginx returns `502 Bad Gateway`

Check:

```bash
sudo systemctl status nginx
```

Then check whether Puma is running.

Check the socket:

```bash
ls -la /home/<deploy_user>/<application_name>/shared/tmp/sockets/
```

Check the Nginx error log:

```bash
sudo tail -f /var/log/nginx/error.log
```

Or, if application-specific logs are configured:

```bash
tail -f /home/<deploy_user>/<application_name>/current/log/nginx.error.log
```

Common causes:

```text
Puma is not running
Puma socket does not exist
Incorrect socket path
Incorrect permissions
Nginx cannot access the socket
Incorrect upstream configuration
```

---

## Nginx configuration error

Run:

```bash
sudo nginx -t
```

Do not reload/restart until the configuration is valid.

---

## Rails application is not responding

Check Puma:

```bash
sudo systemctl status <puma_service>
```

Or check the process:

```bash
ps aux | grep puma
```

Then check Puma logs.

---

## Static assets are not loading

Check:

```text
current/public/assets/
```

Make sure:

* Assets were compiled.
* Nginx `root` points to the correct `public` directory.
* The asset location matches the application's asset configuration.
* Nginx has permission to read the files.

---

# 19. Useful Commands

### Check Nginx version

```bash
nginx -v
```

### Test configuration

```bash
sudo nginx -t
```

### View complete configuration

```bash
sudo nginx -T
```

### Start Nginx

```bash
sudo systemctl start nginx
```

### Stop Nginx

```bash
sudo systemctl stop nginx
```

### Restart Nginx

```bash
sudo systemctl restart nginx
```

### Reload configuration

```bash
sudo systemctl reload nginx
```

### Check status

```bash
sudo systemctl status nginx
```

### Follow Nginx error log

```bash
sudo tail -f /var/log/nginx/error.log
```

### Follow Nginx access log

```bash
sudo tail -f /var/log/nginx/access.log
```

---

# 20. Deployment Checklist

Before considering the Nginx + Puma setup complete:

```text
[ ] Nginx installed
[ ] Nginx service running
[ ] Application configuration created
[ ] Application name/path configured
[ ] Domain configured
[ ] Rails public directory configured
[ ] Puma upstream configured
[ ] Puma Unix socket exists
[ ] Nginx can access the socket
[ ] Static assets configuration reviewed
[ ] Error page exists
[ ] Request body size reviewed
[ ] Nginx configuration tested with nginx -t
[ ] Nginx reloaded successfully
[ ] Application accessible through Nginx
[ ] Nginx access logs checked
[ ] Nginx error logs checked
[ ] Puma logs checked
```

---

# 21. Production Architecture

A typical production Rails deployment looks like:

```text
                    Internet
                       |
                       | HTTP / HTTPS
                       v
                  +----------+
                  |  Nginx   |
                  +----------+
                       |
                       | Unix Socket
                       v
                  +----------+
                  |   Puma   |
                  +----------+
                       |
                       v
                +--------------+
                | Rails App    |
                +--------------+
                  |          |
                  v          v
              Database     Redis
```

Nginx handles the web-facing HTTP layer, while Puma runs the Rails application.

---

# Quick Setup

For a simple deployment, the overall process is:

```bash
# 1. Install Nginx
sudo apt-get update
sudo apt-get install nginx

# 2. Create application configuration
sudo nano /etc/nginx/sites-available/<application_name>

# 3. Enable application
sudo ln -nfs \
  "/etc/nginx/sites-available/<application_name>" \
  "/etc/nginx/sites-enabled/<application_name>"

# 4. Remove default site if necessary
sudo rm /etc/nginx/sites-enabled/default

# 5. Validate configuration
sudo nginx -t

# 6. Reload Nginx
sudo systemctl reload nginx

# 7. Check status
sudo systemctl status nginx
```

> **Important:** Replace all `<placeholders>` with values appropriate for the deployment. Test the configuration with `sudo nginx -t` before reloading Nginx.
