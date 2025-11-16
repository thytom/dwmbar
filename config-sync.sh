#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/dwmbar}"
DEFAULT_CONFIG_DIR="${DEFAULT_CONFIG_DIR:-/usr/share/dwmbar}"

BASH_CONFIG="$CONFIG_DIR/config"
JSON_CONFIG="$CONFIG_DIR/config.json"
BASH_DEFAULT="$DEFAULT_CONFIG_DIR/config"
JSON_DEFAULT="$DEFAULT_CONFIG_DIR/config.json"

command -v jq >/dev/null 2>&1 || exit 0

json_to_bash() {
    local json_file="$1"
    local bash_file="$2"
    
    jq -r '
        "#!/bin/bash\n\n" +
        "# What modules, in what order\n" +
        "MODULES=\"" + ((.modules // []) | map(tostring) | join(" ")) + "\"\n\n" +
        "# Modules that require an active internet connection\n" +
        "ONLINE_MODULES=\"" + ((.online_modules // []) | map(tostring) | join(" ")) + "\"\n\n" +
        "# Delay between showing the status bar\n" +
        "DELAY=\"" + ((.delay // "0.05")|tostring) + "\"\n\n" +
        "# Where the custom modules are stored\n" +
        "CUSTOM_DIR=\"" + (.custom_dir // "/home/$USER/.config/dwmbar/modules/custom/") + "\"\n\n" +
        "# Separator between modules\n" +
        "SEPARATOR=\"" + (.separator // " | ") + "\"\n\n" +
        "# Padding at the end and beginning of the status bar\n" +
        "RIGHT_PADDING=\"" + (.right_padding // " ") + "\"\n" +
        "LEFT_PADDING=\"" + (.left_padding // " ") + "\"\n"
    ' "$json_file" > "$bash_file"
}

bash_to_json() {
    local bash_file="$1"
    local json_file="$2"
    
    local modules online_modules delay custom_dir separator right_padding left_padding
    
    modules=$(grep -E '^MODULES=' "$bash_file" | sed 's/^MODULES="\(.*\)"$/\1/' || echo "")
    online_modules=$(grep -E '^ONLINE_MODULES=' "$bash_file" | sed 's/^ONLINE_MODULES="\(.*\)"$/\1/' || echo "")
    delay=$(grep -E '^DELAY=' "$bash_file" | sed 's/^DELAY="\(.*\)"$/\1/' || echo "0.05")
    custom_dir=$(grep -E '^CUSTOM_DIR=' "$bash_file" | sed 's/^CUSTOM_DIR="\(.*\)"$/\1/' || echo "/home/\$USER/.config/dwmbar/modules/custom/")
    separator=$(grep -E '^SEPARATOR=' "$bash_file" | sed 's/^SEPARATOR="\(.*\)"$/\1/' || echo " | ")
    right_padding=$(grep -E '^RIGHT_PADDING=' "$bash_file" | sed 's/^RIGHT_PADDING="\(.*\)"$/\1/' || echo " ")
    left_padding=$(grep -E '^LEFT_PADDING=' "$bash_file" | sed 's/^LEFT_PADDING="\(.*\)"$/\1/' || echo " ")
    
    local modules_json
    modules_json=$(printf '%s\n' $modules | jq -R . | jq -s .)
    
    local online_modules_json
    online_modules_json=$(printf '%s\n' $online_modules | jq -R . | jq -s .)
    
    jq -n \
        --argjson modules "$modules_json" \
        --argjson online_modules "$online_modules_json" \
        --arg delay "$delay" \
        --arg custom_dir "$custom_dir" \
        --arg separator "$separator" \
        --arg right_padding "$right_padding" \
        --arg left_padding "$left_padding" \
        '{
            modules: $modules,
            online_modules: $online_modules,
            delay: ($delay | tonumber),
            custom_dir: $custom_dir,
            separator: $separator,
            right_padding: $right_padding,
            left_padding: $left_padding
        }' > "$json_file"
}

get_mtime() {
    stat -c %Y "$1" 2>/dev/null || echo 0
}

mkdir -p "$CONFIG_DIR"

if [[ ! -f "$BASH_CONFIG" && ! -f "$JSON_CONFIG" ]]; then
    if [[ -f "$BASH_DEFAULT" ]]; then
        cp "$BASH_DEFAULT" "$BASH_CONFIG"
    fi
    if [[ -f "$JSON_DEFAULT" ]]; then
        cp "$JSON_DEFAULT" "$JSON_CONFIG"
    fi
fi

if [[ -f "$BASH_CONFIG" && ! -f "$JSON_CONFIG" ]]; then
    bash_to_json "$BASH_CONFIG" "$JSON_CONFIG"
elif [[ -f "$JSON_CONFIG" && ! -f "$BASH_CONFIG" ]]; then
    json_to_bash "$JSON_CONFIG" "$BASH_CONFIG"
elif [[ -f "$BASH_CONFIG" && -f "$JSON_CONFIG" ]]; then
    bash_time=$(get_mtime "$BASH_CONFIG")
    json_time=$(get_mtime "$JSON_CONFIG")
    
    if (( bash_time > json_time )); then
        bash_to_json "$BASH_CONFIG" "$JSON_CONFIG"
    elif (( json_time > bash_time )); then
        json_to_bash "$JSON_CONFIG" "$BASH_CONFIG"
    fi
fi
