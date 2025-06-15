#!/usr/bin/env bash
set -euo pipefail

# Auto-detect whether terminal supports emoji (can be overridden by env)
if [[ "${USE_EMOJI:-auto}" == "auto" ]]; then
  if [[ "$LANG" == *"UTF-8"* && -t 1 ]]; then
    USE_EMOJI=true
  else
    USE_EMOJI=false
  fi
fi

# Logging functions
log()     { echo -e "$(prefix "👉" '[ .. ]')" "$*"; }
info()    { echo -e "$(prefix "ℹ️ " '[INFO]')" "$*"; }
warn()    { echo -e "$(prefix "⚠️ " '[WARN]')" "$*" >&2; }
error()   { echo -e "$(prefix "❌" '[FAIL]')" "$*" >&2; exit 1; }
success() { echo -e "$(prefix "✅" '[ OK ]')" "$*"; }

# Emoji-aware prefix function
prefix() {
  if [[ "$USE_EMOJI" == true ]]; then
    echo -n "$1"
  else
    echo -n "$2"
  fi
}
