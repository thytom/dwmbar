#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

rm -rf "/usr/share/dwmbar"
rm -f "/usr/bin/dwmbar"

echo "Completed."
echo "Please delete ~/.config/dwmbar manually, if desired."
