#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/aherbrich/setup-scripts.git"
TARGET_DIR="${HOME}/setup-scripts"

echo "Bootstrapping machine with minimal setup..."

if [[ "$EUID" -eq 0 ]]; then
    echo "Do not run this script as root or with sudo. Exiting."
    exit 1
fi

detect_os() {
    local uname_out
    uname_out="$(uname -s)"

    case "$uname_out" in
        Darwin)
        OS_NAME="macos"
        ;;
        Linux)
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            case "$ID" in
            ubuntu|debian)
                OS_NAME="$ID"
                ;;
            amzn|amazon)
                OS_NAME="amazon-linux"
                ;;
            fedora)
                OS_NAME="fedora"
                ;;
            arch)
                OS_NAME="arch"
                ;;
            *)
                echo "Unrecognized Linux distribution: $ID"
                exit 1
                ;;
            esac
        else
            echo "Could not determine Linux distribution"
            exit 1
        fi
        ;;
        *)
        echo "Unsupported OS: $uname_out"
        exit 1
        ;;
    esac

    echo "Detected OS: $OS_NAME"
}

install_git() {
    echo "Installing git..."
    detect_os
    case "$OS_NAME" in
        amazon-linux)
        sudo dnf install -y git || sudo yum install -y git
        ;;
        macos)
        if ! xcode-select -p &>/dev/null; then
            echo "Installing Xcode Command Line Tools..."
            xcode-select --install

            # Wait until install is complete
            until xcode-select -p &>/dev/null; do
            echo "Waiting for Xcode Command Line Tools to finish installing..."
            sleep 5
            done

            if ! command -v git &>/dev/null; then
                echo "Git not found after installing Xcode Command Line Tools. Exiting."
                exit 1
            fi
        fi
        ;;
        *)
        echo "Unsupported OS for git installation: $OS_NAME"
        exit 1
        ;;
    esac

    echo "Git installed successfully."
}

# Install git if needed
if ! command -v git &>/dev/null; then
    install_git
else
    echo "Git is already installed."
fi

# Clone or update the repo
if [ ! -d "$TARGET_DIR" ]; then
    echo "Cloning setup scripts repository..."
    git clone "$REPO_URL" "$TARGET_DIR"
else
    echo "Repository already exists at $TARGET_DIR. Pulling latest changes..."
    cd "$TARGET_DIR"
    git fetch origin
    git reset --hard origin/main
    git pull origin main
fi

# Run main install script
cd "$TARGET_DIR"
echo "Bootstrapping complete. Running main install script..."
./install.sh
