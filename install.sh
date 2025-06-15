#!/usr/bin/env bash
set -euo pipefail

echo "== Running setup script =="

#############################################
# Step 0: Sanity Check
#############################################

sanity_check() {
  echo "== Step 0: Sanity Check =="

  # Detect OS
  detect_os() {
    if [[ "$(uname)" == "Darwin" ]]; then
      echo "macos"
    elif [[ -f /etc/os-release ]]; then
      . /etc/os-release
      case "$ID" in
        ubuntu) echo "ubuntu" ;;
        amzn|amazon) echo "amazon-linux" ;;
        *) echo "unsupported" ;;
      esac
    else
      echo "unsupported"
    fi
  }

  OS=$(detect_os)
  if [[ "$OS" == "unsupported" ]]; then
    echo "Unsupported OS. Supported: macOS, Ubuntu, Amazon Linux."
    exit 1
  fi
  echo "OS detected: $OS"

  # Internet check
  if ! ping -c 1 -W 3 8.8.8.8 &>/dev/null && ! curl -s --head https://google.com | head -n 1 | grep "HTTP" &>/dev/null; then
    echo "No internet connectivity."
    exit 1
  fi
  echo "Internet connectivity OK"

  # Sudo check
  if ! sudo -n true 2>/dev/null; then
    echo "This script requires sudo access."
    echo "Please run 'sudo -v' and try again."
    exit 1
  fi
  echo "Sudo access verified"

  # Required commands
  REQUIRED_CMDS=("bash" "curl" "git")
  for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "Required command '$cmd' is not installed."
      exit 1
    fi
  done
  echo "Required tools present: ${REQUIRED_CMDS[*]}"

  # Architecture check
  ARCH=$(uname -m)
  if [[ "$ARCH" != "x86_64" && "$ARCH" != "arm64" ]]; then
    echo "Warning: Unexpected architecture: $ARCH"
  else
    echo "Architecture: $ARCH"
  fi

  echo "Sanity check passed."
}

# -----------------------------
# MAIN EXECUTION FLOW
# -----------------------------
sanity_check
echo "Step 0 (sanity check) complete. Ready to proceed."


# Future steps go here...
# install_core_tools
# setup_shell
# link_dotfiles
# ...


