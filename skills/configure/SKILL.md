---
name: configure
description: Configure Telegram Codex bridge token and show setup status. Use when user asks to set up Telegram, save a bot token, check bridge status, or clear Telegram token.
---

# Telegram Codex Configure

Use only for local Codex Telegram bridge setup.

State dir: `~/.codex/channels/telegram`
Env file: `~/.codex/channels/telegram/.env`
Access file: `~/.codex/channels/telegram/access.json`

Arguments from user may be empty, `<token>`, or `clear`.

## Empty Args

Show:

- Token: set/not set. If set, mask after first 10 chars, like `123456789:...`.
- Access: read `access.json`; missing means default `{ "dmPolicy": "pairing", "allowFrom": [], "groups": {}, "pending": {} }`.
- Pending pairing codes, allowlist count, group count.
- Next step:
  - No token: tell user to run this skill with BotFather token.
  - Token set and no allowlisted users: tell user to DM bot, get code, then run access skill with `pair <code>`.
  - User paired: tell user to use `list_messages` tool after Telegram messages arrive.

Always push lockdown: once intended users are paired, recommend access skill `policy allowlist`.

## Token Arg

Treat full argument as Telegram bot token. Create `~/.codex/channels/telegram`.
Read existing `.env` if present, replace or add `TELEGRAM_BOT_TOKEN=<token>`, preserve other keys.
Write file mode `0600`.

Say MCP server must restart/reload after token change.

## clear

Remove `TELEGRAM_BOT_TOKEN=` from `.env`; if file only contained token, remove content.

## Safety

Telegram bot token is credential. Never print full token after saving.
