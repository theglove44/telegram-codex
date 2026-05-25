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

## Quick setup

Goal: after one-time setup, run this from any directory:

```sh
codex-telegram
```

That starts or reuses a `codex-telegram` tmux session, runs Codex in the current directory, starts the Telegram injector, and attaches to tmux.

### 1. Clone and install

```sh
git clone git@github.com:theglove44/telegram-codex.git ~/plugins/telegram-codex
cd ~/plugins/telegram-codex
bun install
```

### 2. Register the Codex MCP server

```sh
codex mcp add telegram-codex -- bun run --cwd "$HOME/plugins/telegram-codex" --shell=bun --silent start
```

If you installed the repo somewhere else, replace `$HOME/plugins/telegram-codex` with that path.

### 3. Install the plugin metadata

If `~/plugins` is already configured as the `personal` marketplace:

```sh
codex plugin add telegram-codex@personal
```

If not, add the marketplace first:

```sh
codex plugin marketplace add "$HOME"
codex plugin add telegram-codex@personal
```

Restart Codex after adding the MCP server/plugin.

### 4. Configure Telegram token

Create a Telegram bot with `@BotFather`, then save the token:

```sh
mkdir -p ~/.codex/channels/telegram
printf 'TELEGRAM_BOT_TOKEN=<your-bot-token>\n' > ~/.codex/channels/telegram/.env
chmod 600 ~/.codex/channels/telegram/.env
```

Do not commit this file.

### 5. Pair your Telegram account

1. Start/restart Codex so the MCP server is polling.
2. DM your bot.
3. The bot replies with a code.
4. In Codex, run:

```text
telegram-codex access pair <code>
```

Then lock DMs down to paired users:

```text
telegram-codex access policy allowlist
```

### 6. Add the one-command alias

Add this to `~/.zshrc`:

```sh
alias codex-telegram='$HOME/plugins/telegram-codex/scripts/start-tmux-live.sh && tmux attach -t codex-telegram'
alias codex-telegram-skip='TELEGRAM_CODEX_SKIP_PERMISSIONS=1 $HOME/plugins/telegram-codex/scripts/start-tmux-live.sh && tmux attach -t codex-telegram'
```

Reload your shell:

```sh
source ~/.zshrc
```

### 7. Use it from any project directory

```sh
cd ~/Projects/my-project
codex-telegram
```

To avoid approval prompts in the Telegram session:

```sh
codex-telegram-skip
```

This starts Codex with `--dangerously-bypass-approvals-and-sandbox`. Only use it with a paired, allowlisted bot you control.

If a `codex-telegram` tmux session already exists, stop it first so the skip-permissions flag applies to a fresh Codex process:

```sh
tmux kill-session -t codex-telegram
codex-telegram-skip
```

First run creates a `codex-telegram` tmux session with:

- Codex pane: `codex-telegram:1.1`
- Injector pane: `codex-telegram:2.1`

If the session already exists, it reuses the existing Codex pane. To change project directory cleanly, stop the old session first:

```sh
tmux kill-session -t codex-telegram
cd ~/Projects/other-project
codex-telegram
```

Check from Telegram:

```text
/status
```

## Manual setup

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
