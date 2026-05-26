#!/usr/bin/env bash
set -u

target="${1:-}"
delay="${TELEGRAM_CODEX_INJECTOR_RESTART_DELAY:-5}"

if [[ -z "$target" ]]; then
  echo "usage: supervise-tmux-injector.sh <tmux-target>" >&2
  exit 2
fi

while true; do
  npm run tmux-injector -- --target "$target"
  status=$?
  printf '[%s] telegram injector exited with status %s; restarting in %ss\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$status" "$delay" >&2
  sleep "$delay"
done
