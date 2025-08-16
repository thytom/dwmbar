#!/usr/bin/env bash
set -euo pipefail

# Copyright 2019 Archie Hilton <archie.hilton1@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    echo "Elevating with sudo to install to system directories..."
    exec sudo -E bash "$0" "$@"
  else
    echo "Please run as root (sudo not found)." >&2
    exit 1
  fi
fi

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT="$SCRIPT_DIR"

[[ -f "$REPO_ROOT/dwmbar" ]] || { echo "dwmbar executable not found." >&2; exit 1; }
[[ -d "$REPO_ROOT/modules" ]] || { echo "modules directory not found." >&2; exit 1; }
[[ -f "$REPO_ROOT/bar.sh" ]] || { echo "bar.sh not found." >&2; exit 1; }
[[ -f "$REPO_ROOT/config" ]] || { echo "config file not found." >&2; exit 1; }

BIN_DEST="/usr/bin/dwmbar"
SHARE_DIR="/usr/share/dwmbar"
MOD_DEST="$SHARE_DIR/modules"
LIB_DEST="$SHARE_DIR/lib"

install -d "$SHARE_DIR"

rm -rf "$MOD_DEST"
cp -rT "$REPO_ROOT/modules" "$MOD_DEST"
cp -rT "$REPO_ROOT/lib" "$LIB_DEST"

install -m 0755 "$REPO_ROOT/bar.sh" "$SHARE_DIR/bar.sh"
install -m 0644 "$REPO_ROOT/config" "$SHARE_DIR/config"

# Install optional JSON config if present
if [[ -f "$REPO_ROOT/config.json" ]]; then
  install -m 0644 "$REPO_ROOT/config.json" "$SHARE_DIR/config.json"
fi

install -m 0755 "$REPO_ROOT/dwmbar" "$BIN_DEST"

echo "Installation completed successfully."
