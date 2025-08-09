#!/usr/bin/env bash
# Simple TTL cache helpers

_cache_dir() {
  if [[ -n "${CACHE_DIR:-}" ]]; then
    echo "$CACHE_DIR"
    return
  fi
  if [[ -n "${XDG_CACHE_HOME:-}" ]]; then
    echo "$XDG_CACHE_HOME/dwmbar/"
  else
    echo "/tmp/dwmbar/"
  fi
}

_cache_path() {
  local key="$1"
  local dir
  dir=$(_cache_dir)
  mkdir -p "$dir"
  # Sanitize key into filename
  local file_key
  file_key=$(echo "$key" | tr '/ ' '__')
  echo "${dir%/}/${file_key}"
}

cache_read() {
  # Usage: cache_read key ttl_seconds
  local key="$1" ttl="$2"
  local path
  path=$(_cache_path "$key")
  if [[ -f "$path" ]]; then
    local age
    age=$(( $(date +%s) - $(stat -c %Y "$path" 2>/dev/null || echo 0) ))
    if (( age < ttl )); then
      cat "$path"
      return 0
    fi
  fi
  return 1
}

cache_write() {
  # Usage: cache_write key value
  local key="$1"; shift
  local value="$*"
  local path
  path=$(_cache_path "$key")
  printf "%s" "$value" > "$path"
}
