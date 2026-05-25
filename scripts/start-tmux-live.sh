#!/usr/bin/env bash
set -euo pipefail

SESSION="${TELEGRAM_CODEX_SESSION:-codex-telegram}"
CODEX_WINDOW="${TELEGRAM_CODEX_CODEX_WINDOW:-codex}"
INJECTOR_WINDOW="${TELEGRAM_CODEX_INJECTOR_WINDOW:-telegram-injector}"
PLUGIN_DIR="${TELEGRAM_CODEX_PLUGIN_DIR:-$HOME/plugins/telegram-codex}"
TARGET="${TELEGRAM_CODEX_TARGET:-$SESSION:1.1}"
CODEX_CWD="${TELEGRAM_CODEX_CWD:-$PWD}"

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux required" >&2
  exit 1
fi

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux new-session -d -s "$SESSION" -n "$CODEX_WINDOW" -c "$CODEX_CWD" 'codex'
else
  if tmux display-message -p -t "$TARGET" '#{pane_id}' >/dev/null 2>&1; then
    :
  elif ! tmux list-windows -t "$SESSION" -F '#{window_name}' | grep -qx "$CODEX_WINDOW"; then
    tmux new-window -d -t "$SESSION" -n "$CODEX_WINDOW" -c "$CODEX_CWD" 'codex'
  fi
fi

if tmux list-windows -t "$SESSION" -F '#{window_name}' | grep -qx "$INJECTOR_WINDOW"; then
  tmux kill-window -t "$SESSION:$INJECTOR_WINDOW"
fi

tmux new-window -d -t "$SESSION" -n "$INJECTOR_WINDOW" \
  "cd '$PLUGIN_DIR' && npm run tmux-injector -- --target '$TARGET'"

cat <<EOF
Codex Telegram live mode started.

Codex pane:    $TARGET
Injector pane: $SESSION:$INJECTOR_WINDOW
Codex cwd:     $CODEX_CWD

Attach:
  tmux attach -t $SESSION

Telegram controls:
  /pause   pause injection
  /resume  resume injection
  /status  show injector status
EOF
