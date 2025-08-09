SHELL := bash
.ONESHELL:

.PHONY: test lint fmt ci

# Run module tests
test:
	./tests/run.sh

# Lint shell scripts with shellcheck (if installed)
lint:
	@command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck not installed"; exit 0; }
	@echo "Running shellcheck..."
	@find modules -maxdepth 1 -type f -exec shellcheck -x -P SCRIPTDIR {} +
	@shellcheck -x -P SCRIPTDIR bar.sh dwmbar

# Format with shfmt (if installed)
fmt:
	@command -v shfmt >/dev/null 2>&1 || { echo "shfmt not installed"; exit 0; }
	@echo "Running shfmt..."
	@shfmt -w -i 4 -ci -sr bar.sh dwmbar modules/*

# CI target: lint + test
ci: lint test
