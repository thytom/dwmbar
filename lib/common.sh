#!/usr/bin/env bash
# Common helpers for dwmbar modules

# Ensure predictable parsing
export LANG=${LANG:-C}
export LC_ALL=${LC_ALL:-C}

have() { command -v "$1" >/dev/null 2>&1; }

read_sys() {
  # Usage: read_sys /sys/path
  local path="$1"
  [[ -r "$path" ]] || return 1
  cat "$path" 2>/dev/null
}

safe_curl() {
  # Usage: safe_curl URL [timeout_seconds]
  local url="$1"; shift || true
  local t=${1:-2}
  have curl || return 1
  curl -s --max-time "$t" "$url"
}
