#!/bin/bash

DWMBAR="/usr/bin/dwmbar"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

if [[ ! -f "dwmbar" ]]; then
	echo "dwmbar executable not found."
fi

# Create /usr/share/dwmbar
# Containing example dwmbarrc and modules

mkdir --parents "/usr/share/dwmbar/"

cp -r "./modules" "/usr/share/dwmbar/modules"
cp -r "./dwmbarrc" "/usr/share/dwmbar/dwmbarrc"

echo "./dwmbar --> /usr/bin/dwmbar"
cp "./dwmbar" "/usr/bin/dwmbar"
[[ $? -eq 0 ]] && echo "Installation completed successfully"
