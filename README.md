# mx-puppet-groupme

Upstream: https://gitlab.com/robintown/mx-puppet-groupme

A puppeting Matrix bridge for GroupMe built with mx-puppet-bridge

For discussion and support, join us on Matrix at [#mx-puppet-groupme:townsendandsmith.ml](https://matrix.to/#/#mx-puppet-groupme:townsendandsmith.ml).

## Credits

- GroupMe v3 API compatibility fixes (2025) were implemented with the help of **[Cursor](https://cursor.com)** (AI-assisted development). See `FIXES-APPLIED.md` for details.
- Matrix Spaces support (2026) was also implemented with Cursor assistance.

## Setup

### Prerequisites

First, install the dependencies:

```
npm install
```

Create a configuration file and edit it appropriately:

```
cp sample.config.yaml config.yaml
editor config.yaml
```

Then generate an appservice registration file (defaults to `groupme-registration.yaml`):

```
npm run start -- --register
```

### Synapse Configuration

Add the registration file path to `app_service_config_files` in your Synapse `homeserver.yaml`:

```yaml
app_service_config_files:
  - /path/to/groupme-registration.yaml
```

**Important:** Due to a case-sensitivity issue in the underlying bot-sdk library (it checks for `Authorization` header with uppercase, but Express lowercases all headers), you must also add this setting to your `homeserver.yaml`:

```yaml
use_appservice_legacy_authorization: true
```

This makes Synapse send the `hs_token` as a query parameter instead of an Authorization header, which works around the issue.

After making these changes, restart Synapse.

### Running the Bridge

You can now run the bridge:

```
npm run start
```

### Docker Setup

When running in Docker, ensure the `docker-run.sh` script has Unix (LF) line endings, not Windows (CRLF). The script expects these environment variables:

- `CONFIG_PATH` - Path to config.yaml (e.g., `/data/config.yaml`)
- `REGISTRATION_PATH` - Path to registration file (e.g., `/data/groupme-registration.yaml`)

Example docker-compose.yml service:

```yaml
mx-puppet-groupme:
  build: .
  container_name: matrix-mx-puppet-groupme
  depends_on:
    - synapse
  restart: unless-stopped
  volumes:
    - ./mx-puppet-groupme/data:/data
  networks:
    - matrix_net
  environment:
    - CONFIG_PATH=/data/config.yaml
    - REGISTRATION_PATH=/data/groupme-registration.yaml
```

For Docker deployments, set `bridge.bindAddress` to `0.0.0.0` in your config.yaml, and use the Docker service name for `bridge.homeserverUrl` (e.g., `http://synapse:8008`).

## Usage

Start a chat with `@_groupmepuppet_bot:<your homeserver>`. You may type `help` to view available commands.

To link your GroupMe account, go to [dev.groupme.com](https://dev.groupme.com/), sign in, and select "Access Token" from the top menu. Copy the token and message the bridge with:

```
link <access token>
```

Note the puppet ID that it returns. (You can find it later with `list`.)

### Bridging Commands

- `bridgeeverything <puppetId>` - Bridge all groups and DMs at once
- `bridgeallgroups <puppetId>` - Bridge all groups you are in
- `bridgealldms <puppetId>` - Bridge all your DMs
- `bridgegroup <puppetId> <groupId>` - Bridge a specific group
- `unbridgegroup <puppetId> <groupId>` - Unbridge a specific group

### Matrix Spaces

The bridge supports organizing your GroupMe rooms into a Matrix Space for easier navigation:

- `createspace <puppetId>` - Create a Matrix Space for your GroupMe rooms
- `syncspace <puppetId>` - Add all bridged rooms to your GroupMe Space

When you use `bridgeeverything`, `bridgeallgroups`, or `bridgealldms`, rooms are automatically added to your Space if one exists.

### Other Commands

- `listusers <puppetId>` - Show the user directory
- `listrooms <puppetId>` - Show the group directory
- `invite <puppetId> <roomId>` - Get invited back to a room
