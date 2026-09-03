# Install Node.js for Rails Development

Node.js is commonly used in Rails applications for JavaScript dependencies, asset bundling, and frontend tooling.

The exact Node.js version should match the requirements of the Rails application and its JavaScript dependencies.

## 1. Check Whether Node.js Is Already Installed

```bash
node --version
npm --version
```

If Node.js is installed, verify that the version is compatible with the application's `package.json` and Rails setup.

---

## 2. Install Node.js

For a Debian/Ubuntu-based development environment, NodeSource can be used to install a specific Node.js major version.

Example using Node.js 20:

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

Verify the installation:

```bash
node --version
npm --version
```

Expected output will be similar to:

```text
v20.x.x
10.x.x
```

The exact versions may differ as Node.js and npm releases change.

---

## 3. Verify Node.js in a Rails Application

From the Rails application's root directory:

```bash
node --version
npm --version
```

Check whether the application defines a required Node.js version:

```bash
cat package.json
```

Look for an `engines` section such as:

```json
{
  "engines": {
    "node": ">=20"
  }
}
```

The project may also specify a Node.js version using files such as:

```text
.node-version
.nvmrc
```

For example:

```bash
cat .nvmrc
```

If the project specifies a version, use that version rather than arbitrarily installing a different major version.

---

## 4. Install JavaScript Dependencies

If the Rails application already contains a `package.json`, install its dependencies from the application root.

With npm:

```bash
npm install
```

For reproducible installations in CI or deployment environments, prefer:

```bash
npm ci
```

`npm ci` uses the existing `package-lock.json` and is intended for clean, repeatable installations.

---

## 5. Rails JavaScript Tooling

Depending on the Rails version and application setup, Node.js may be used with tools such as:

* `importmap-rails`
* `jsbundling-rails`
* `webpack`
* `esbuild`
* `rollup`
* `vite`
* `npm`
* other frontend build tools

For example, a Rails application using `jsbundling-rails` may have build scripts in `package.json`:

```json
{
  "scripts": {
    "build": "esbuild app/javascript/*.* --bundle --sourcemap --outdir=app/assets/builds"
  }
}
```

The actual commands depend on the application's JavaScript configuration.

---

## 6. Test the JavaScript Build

After installing dependencies, run the application's configured build command.

For example:

```bash
npm run build
```

If the application defines additional scripts, inspect them with:

```bash
npm run
```

This displays the available npm scripts.

---

## 7. Verify Rails and Node.js Together

From the Rails application directory:

```bash
ruby --version
bundle --version
rails --version
node --version
npm --version
```

A healthy development environment should have all required runtimes and package managers available.

---

## 8. Common Troubleshooting

### `node: command not found`

Verify that Node.js was installed:

```bash
sudo apt-get update
sudo apt-get install -y nodejs
```

Then check:

```bash
node --version
```

---

### Node.js Version Is Incorrect

Check the project's version files:

```bash
cat .nvmrc
cat .node-version
```

Also inspect `package.json`:

```bash
grep -A 5 '"engines"' package.json
```

Use the Node.js version required by the application.

---

### npm Dependencies Fail to Install

First verify the versions:

```bash
node --version
npm --version
```

Then try a clean installation:

```bash
rm -rf node_modules
npm ci
```

Only remove `package-lock.json` when intentionally regenerating dependency resolution. It should normally be kept under version control.

---

### Build Command Fails

List the available scripts:

```bash
npm run
```

Then inspect the relevant script in:

```bash
cat package.json
```

For Rails applications, also check:

```text
app/javascript/
app/assets/
package.json
```

and any Rails-specific JavaScript configuration.

---

## 9. Development Environment Checklist

* [ ] Node.js is installed
* [ ] Node.js version matches the application requirements
* [ ] npm is available
* [ ] `package.json` exists when required
* [ ] `package-lock.json` is committed when using npm
* [ ] JavaScript dependencies install successfully
* [ ] The configured asset/build command runs successfully
* [ ] Rails can start without JavaScript build errors

## Quick Reference

| Task                       | Command                                                              |
| -------------------------- | -------------------------------------------------------------------- |
| Check Node.js              | `node --version`                                                     |
| Check npm                  | `npm --version`                                                      |
| Install Node.js 20         | `curl -fsSL https://deb.nodesource.com/setup_20.x \| sudo -E bash -` |
| Install Node.js package    | `sudo apt-get install -y nodejs`                                     |
| Install dependencies       | `npm install`                                                        |
| Clean/reproducible install | `npm ci`                                                             |
| List npm scripts           | `npm run`                                                            |
| Run build                  | `npm run build`                                                      |

> **Note:** Node.js 20 is an example. For a Rails application, use the Node.js version supported by the project's Rails, JavaScript tooling, and dependency requirements.
