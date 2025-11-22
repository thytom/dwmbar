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
if [[ -n $CACHE_DIR ]]; then
	OUTPUT_CACHE="$CACHE_DIR"
else
	OUTPUT_CACHE="/home/$USER/.config/dwmbar/.cache/"
fi

export LC_ALL=C
export LANG=C

if [[ "$CONFIG_FILE" == *.json ]]; then
	MODULES=$(jq -r '.modules | join(" ")' "$CONFIG_FILE")
	ONLINE_MODULES=$(jq -r '.online_modules | join(" ")' "$CONFIG_FILE")
	DELAY=$(jq -r '.delay // 0.05' "$CONFIG_FILE")
	SEPARATOR=$(jq -r '.separator // " | "' "$CONFIG_FILE")
	LEFT_PADDING=$(jq -r '.left_padding // " "' "$CONFIG_FILE")
	RIGHT_PADDING=$(jq -r '.right_padding // " "' "$CONFIG_FILE")
	CUSTOM_DIR=$(jq -r '.custom_dir' "$CONFIG_FILE")
	CUSTOM_DIR="${CUSTOM_DIR/#\~/$HOME}"
	CUSTOM_DIR="${CUSTOM_DIR/\$USER/$USER}"
	CUSTOM_DIR="${CUSTOM_DIR/\$HOME/$HOME}"
	[[ -z "$CUSTOM_DIR" ]] && CUSTOM_DIR="$HOME/.config/dwmbar/modules/custom/"
else
	# shellcheck source=/dev/null
	source "$CONFIG_FILE"
fi

export SEPARATOR
export MODULES
export ONLINE_MODULES
export DELAY
export LEFT_PADDING
export RIGHT_PADDING
export CUSTOM_DIR

get_bar()
{
	local bar=""
	local first=true
	
	for module in $MODULES; do
        if [[ $INTERNET -eq 0 ]] || [[ $ONLINE_MODULES != *"$module"* ]]; then
            module_out="$(cat "$OUTPUT_CACHE$module" 2>/dev/null)"
			
			if [[ -n "$module_out" ]]; then
				if [[ "$first" == true ]]; then
					bar="$module_out"
					first=false
				else
					bar="$bar$SEPARATOR$module_out"
				fi
			fi
		fi
	done
	
	echo "$LEFT_PADDING$bar$RIGHT_PADDING"
}

run_module()
{
	if [[ -f "$CUSTOM_DIR$1" ]]
	then
		out="$("$CUSTOM_DIR""$1")"
	else
		out="$("$DEFAULT_MODULES_DIR""$1")"
	fi

	if [[ "$out" = " " ]]; then
		echo "" > "$OUTPUT_CACHE$module"
	else
		echo "$out" > "$OUTPUT_CACHE$module"
	fi
}

run()
{
	for module in $MODULES; do
		[[ ! -f "$OUTPUT_CACHE$module" ]] && touch "$OUTPUT_CACHE$module"
		pgrep "$module" &> /dev/null
		notrunning=$([[ $? -eq 1 ]])
		if $notrunning && [[ $INTERNET -eq 0 ]]; then
			run_module "$module"
		elif $notrunning && [[ $INTERNET -eq 1 ]]; then
			[[ "$ONLINE_MODULES" != *"$module"* ]] && run_module "$module"
		fi
	done

	get_bar
	sleep "$DELAY";
}

run
