#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${ROOT_DIR}/scripts"
LIB_DIR="${ROOT_DIR}/lib"

# Source logging helper
source "${LIB_DIR}/log.sh"
source "${LIB_DIR}/detect-os.sh"

info "Starting full system setup..."

# Run scripts in order
for step in \
    "01-core.sh" \
    "02-shell.sh" \
    "03-devtools.sh" \
    "04-runtimes.sh"
do
    SCRIPT_PATH="${SCRIPTS_DIR}/${step}"
    if [[ -x "$SCRIPT_PATH" ]]; then
        info "Running step: ${step}"
        "$SCRIPT_PATH"
    else
        warn "Skipping missing or non-executable script: ${step}"
    fi
done

success "✅ Setup complete! You're ready to go."
