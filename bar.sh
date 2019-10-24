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

CONFIG_NAME="config"

DELAY=$(cat $CONFIG_NAME | grep -E "DELAY" | cut -d '"' -f2)
MODULES_DIR="/home/$USER/.config/dwmbar/modules/"
CUSTOM_DIR=$(cat $CONFIG_NAME | grep -E "CUSTOM_DIR" | cut -d '"' -f2)
SEPARATOR=$(cat $CONFIG_NAME | grep -E "SEPARATOR" | cut -d '"' -f2)
PADDING=$(cat $CONFIG_NAME | grep -E "PADDING" | cut -d '"' -f2)

OUTPUT_CACHE="/home/$USER/.config/dwmbar/.cache/"
OUTPUT=""

# What modules, in what order
MODULES=$(cat $CONFIG_NAME | grep -E "MODULES" | cut -d '"' -f2)

# Modules that require an active internet connection
ONLINE_MODULES=$(cat $CONFIG_NAME | grep -E "ONLINE_MODULES" | cut -d '"' -f2)

INTERNET=1 #0 being true

get_internet()
{
    curl -q http://google.com &> /dev/null

    if [[ $? -eq 0 ]]; then
        INTERNET=0
    else
        INTERNET=1
    fi
}

get_bar()
{
	for module in $MODULES; do
		if [[ $INTERNET -eq 0 ]] || [[ $ONLINE_MODULES != *"$module"* ]];then
			module_out=$(cat $OUTPUT_CACHE$module | sed 's/\.$//g')
			bar=$bar$module_out
		fi
	done
	# Uncomment to remove last separator
	# bar=$(echo $bar | sed 's/.$//g')
	echo "$bar$PADDING"
}

run_module()
{
	if [[ -f "$CUSTOM_DIR$1" ]]
	then
		out="$(exec $CUSTOM_DIR$1)"
	else
		out="$(exec $MODULES_DIR$1)"
	fi

	[[ ! "$out" = "" ]] && [[ ! "$module" = "NULL" ]] && out="$out$SEPARATOR."
	echo $out > "$OUTPUT_CACHE$module"
}

run()
{
    get_internet
	for module in $MODULES; do
		if [[ $INTERNET -eq 0 ]]; then
			run_module $module
		else
			[[ $ONLINE_MODULES != *"$module"* ]] && run_module $module
		fi
	done
	get_bar
	sleep $DELAY;
}

run
