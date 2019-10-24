#!/bin/bash

# Copyright 2019 Archie Hilton <archie.hilton1@gmail.com>

# This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <https://www.gnu.org/licenses/>.

DWMBAR="/usr/bin/dwmbar"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root" > /dev/stderr
  exit 1
fi

if [[ ! -f "dwmbar" ]]; then
	echo "dwmbar executable not found." > /dev/stderr
	exit 1
fi

# Create /usr/share/dwmbar
# Containing example bar.sh and modules

mkdir --parents "/usr/share/dwmbar/"

echo "./modules --> /usr/share/dwmbar/modules"
cp -r "./modules" "/usr/share/dwmbar/modules"

echo "./bar.sh --> /usr/share/dwmbar/bar.sh"
cp "./bar.sh" "/usr/share/dwmbar/bar.sh"

echo "./config --> /usr/share/dwmbar/config"
cp -r "./config" "/usr/share/dwmbar/config"

echo "./dwmbar --> /usr/bin/dwmbar"
cp "./dwmbar" "/usr/bin/dwmbar"
[[ $? -eq 0 ]] && echo "Installation completed successfully"
