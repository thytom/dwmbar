#!/bin/bash

CONFIG_DIR="/home/$USER/.config/dwmbar"
MODULES_DIR="$CONFIG_DIR/modules"
DWMBARRC="$CONFIG_DIR/dwmbarrc"
DWMBAR="/usr/bin/dwmbar"

if [[ ! -f "dwmbar" ]]; then
	echo "dwmbar executable not found."
fi

install()
{
	cp "./dwmbar" "/usr/bin/dwmbar"

	mkdir -p "$CONFIG_DIR"

	[[ ! -f "$MODULES_DIR" ]] && cp  -r "./modules" "$CONFIG_DIR/modules"
	[[ ! -f "$DWMBARRC" ]] && cp "./dwmbarrc" "$DWMBARRC"
}

install
