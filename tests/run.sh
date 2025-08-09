#!/usr/bin/env bash
set -uo pipefail

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")"/.. && pwd)
MODULES_DIR="$ROOT_DIR/modules"
MOCKS_DIR="$ROOT_DIR/tests/mocks"
FIXTURES_DIR="$ROOT_DIR/tests/fixtures"

# Prepend mocks to PATH so module scripts hit our stubs first
export PATH="$MOCKS_DIR:$PATH"

# Point modules that support overrides at fixtures
export NET_DIR="$FIXTURES_DIR/sys/class/net"
export NET_STAT_DIR="$FIXTURES_DIR/sys/class/net"
export WIRELESS_FILE="$FIXTURES_DIR/proc/net/wireless"
export PUBLIC_IP_URL="https://ifconfig.co"
export WEATHER_URL="https://v2.wttr.in"
export WEATHER_LOCATION="TestCity"
export TASKS_DIR="$FIXTURES_DIR/todo"
export MAIL_DIR="$FIXTURES_DIR/mail/INBOX/new"
export LOCAL_IP_IFACE="eth0"
export CPU_TEMP_WARN=70
export ARCH_UPDATES_CACHE_SECONDS=1

mkdir -p "$ROOT_DIR/tests/out"

pass=0
fail=0

echo "Running module checks..."

for module_path in "$MODULES_DIR"/*; do
  module_name=$(basename "$module_path")
  # Run each module with bash to avoid relying on file mode bits
  out_file="$ROOT_DIR/tests/out/${module_name}.out"
  err_file="$ROOT_DIR/tests/out/${module_name}.err"

  # Timeout each module to 3s in case of regression hangs
  if command -v timeout >/dev/null 2>&1; then
    timeout_cmd=(timeout 3s)
  else
    timeout_cmd=()
  fi

  "${timeout_cmd[@]}" bash "$module_path" >"$out_file" 2>"$err_file"
  status=$?

  # Optional golden output assertion
  if [[ -f "$ROOT_DIR/tests/expected/${module_name}.txt" ]]; then
    if ! diff -u "$ROOT_DIR/tests/expected/${module_name}.txt" "$out_file" >/dev/null 2>&1; then
      echo "FAIL $module_name (output mismatch)"
      echo "  expected: $(cat "$ROOT_DIR/tests/expected/${module_name}.txt")"
      echo "  actual:   $(cat "$out_file")"
      status=1
    fi
  fi

  if [[ $status -eq 0 ]]; then
    echo "PASS $module_name"
    pass=$((pass+1))
  else
    echo "FAIL $module_name (exit $status)"
    echo "  stderr: $(tr -d '\n' <"$err_file" | head -c 200)"
    fail=$((fail+1))
  fi

done

echo
echo "Summary: $pass passed, $fail failed"
[[ $fail -eq 0 ]] || exit 1
