#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/log.sh"

if [[ -z "${OS_NAME:-}" ]]; then
    error "OS_NAME is not set. Please call this script only from ./install.sh or ensure OS detection is done first."
else
    info "Using detected OS: $OS_NAME"
fi


info "Running core system setup for: $OS_NAME"

case "$OS_NAME" in
    macos)
        if ! xcode-select -p >/dev/null 2>&1; then
            info "Xcode Command Line Tools not found. Please install them first."
            echo "Run 'xcode-select --install' in your terminal. After installation, re-run this script."
            exit 1
        else
            info "Xcode Command Line Tools found. Proceeding with setup."
        fi
        if ! command -v brew >/dev/null; then
        info "Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
        info "Homebrew already installed"
        fi

        log "Updating Homebrew"
        brew update
        brew upgrade
        brew cleanup

        log "Installing core tools"
        brew install git curl vim zsh ca-certificates openssh wget

        ;;

    amazon-linux)
        log "Updating DNF..."
        sudo dnf update -y

        log "Installing core packages"
        sudo dnf install -y \
            git \
            curl \
            vim \
            zsh \
            gcc \
            gcc-c++ \
            make \
            zlib-devel \
            glibc-devel \
            ca-certificates \
            openssh \
            wget

        ;;

    *)
        error "Unsupported or unrecognized OS: $OS_NAME"
        ;;
esac

success "Core setup completed for $OS_NAME"
