#!/usr/bin/env bash
set -euo pipefail

detect_os() {
  local uname_out
  uname_out="$(uname -s)"

  case "$uname_out" in
    Darwin)
      export OS_NAME="macos"
      export PACKAGE_MANAGER="brew"
      ;;
    Linux)
      if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        case "$ID" in
          ubuntu)
            export OS_NAME="ubuntu"
            export PACKAGE_MANAGER="apt"
            ;;
          debian)
            export OS_NAME="debian"
            export PACKAGE_MANAGER="apt"
            ;;
          amzn | amazon)
            export OS_NAME="amazon-linux"
            export PACKAGE_MANAGER="dnf"
            ;;
          fedora)
            export OS_NAME="fedora"
            export PACKAGE_MANAGER="dnf"
            ;;
          arch)
            export OS_NAME="arch"
            export PACKAGE_MANAGER="pacman"
            ;;
          *)
            warn "Unrecognized Linux distribution: $ID"
            export OS_NAME="$ID"
            export PACKAGE_MANAGER="unknown"
            ;;
        esac
      else
        error "Could not determine Linux distribution"
      fi
      ;;
    *)
      error "Unsupported OS: $uname_out"
      ;;
  esac

  info "Detected OS: $OS_NAME"
}

detect_os
