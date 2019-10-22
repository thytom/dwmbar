#!/bin/bash

CONFIG_DIR="/home/$USER/.config/dwmbar"
MODULES_DIR="$CONFIG_DIR/modules"
CUSTOM_DIR="$MODULES_DIR/custom"
DWMBARRC="$CONFIG_DIR/dwmbarrc"
DWMBAR="/usr/bin/dwmbar"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 0
fi

if [[ ! -f "dwmbar" ]]; then
	echo "dwmbar executable not found."
fi

cp "./dwmbar" "/usr/bin/dwmbar"

mkdir -p "$CUSTOM_DIR"

for script in $(ls modules); do
	echo "modules/$script -> $MODULES_DIR/$script"
	cp "modules/$script" "$MODULES_DIR/$script"
done

[[ ! -f "$DWMBARRC" ]] && cp "./dwmbarrc" "$DWMBARRC"
