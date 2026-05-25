# Telegram Codex

Local Codex plugin port of Anthropic's Claude Code Telegram plugin.

It runs a Telegram bot as an MCP server. Codex gets tools:

- `list_messages`: read inbound Telegram messages captured in `~/.codex/channels/telegram/messages.jsonl`
- `reply`: send Telegram replies and attachments
- `react`: react to Telegram messages
- `edit_message`: edit bot-sent messages
- `download_attachment`: download Telegram file attachments into local inbox

Codex does not use Claude Code's `--channels` flow, so inbound Telegram messages are stored locally and read with `list_messages`.

For Claude-like live TUI operation, run Codex inside `tmux` and start the tmux injector. It tails `messages.jsonl`, pastes a wrapped `<channel source="plugin:telegram">` message into the Codex pane, and presses Enter.

## Setup

1. Create a Telegram bot with `@BotFather`.
2. Configure token with the `telegram-codex:configure` skill, or write:

```sh
mkdir -p ~/.codex/channels/telegram
printf 'TELEGRAM_BOT_TOKEN=123456789:AAH...\n' > ~/.codex/channels/telegram/.env
chmod 600 ~/.codex/channels/telegram/.env
```

3. Load this plugin in Codex, restart/reload plugins.
4. DM the bot. It replies with a pairing code.
5. Run `telegram-codex:access pair <code>` in Codex.
6. After pairing, ask Codex to use `list_messages`, then `reply`.

## tmux live TUI mode

Start Codex in tmux:

```sh
tmux new -s codex
codex
```

Find the pane target:

```sh
tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_current_command} #{pane_active}'
```

Start injector from another terminal:

```sh
cd ~/plugins/telegram-codex
npm run tmux-injector -- --target codex:0.0
```

New Telegram DMs from allowlisted users will be submitted into the live Codex TUI. Codex should answer by calling `mcp__telegram_codex__.reply`.

Or launch/restart the standard tmux setup:

```sh
cd ~/plugins/telegram-codex
npm run tmux-live
```

Telegram control commands:

- `/pause` or `/stop` pauses injection.
- `/resume` or `/start` resumes injection.
- `/status` reports injector status.

The injector health-checks the target pane and exits if it appears to be Claude Code instead of Codex.

Lock down after pairing:

```text
telegram-codex:access policy allowlist
```

Manual MCP config example:

```json
{
  "mcpServers": {
    "telegram-codex": {
      "command": "bun",
      "args": [
        "run",
        "--cwd",
        "/path/to/telegram-codex",
        "--shell=bun",
        "--silent",
        "start"
      ]
    }
  }
}
```

Replace `/path/to/telegram-codex` with your local clone path. Do not commit `~/.codex/channels/telegram/.env`, `access.json`, or any bot token.

## State

State lives in `~/.codex/channels/telegram` unless `TELEGRAM_STATE_DIR` is set.

Source adapted from:
https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/telegram
