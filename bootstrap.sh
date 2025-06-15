#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/aherbrich/setup-scripts.git"
TARGET_DIR="${HOME}/setup-scripts"

echo "Bootstrapping machine with minimal setup..."

if [[ "$EUID" -eq 0 ]]; then
  echo "Do not run this script as root or with sudo. Exiting."
  exit 1
fi

# Function to detect OS
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

# Function to install git
install_git() {
  echo "Installing git..."
  OS=$(detect_os)

  case "$OS" in
    ubuntu)
      sudo apt-get update
      sudo apt-get install -y git
      ;;
    amazon-linux)
      sudo dnf install -y git || sudo yum install -y git
      ;;
    macos)
      if ! xcode-select -p > /dev/null 2>&1; then
        echo "Installing Xcode Command Line Tools..."
        xcode-select --install
        echo "Please complete the Xcode installation manually if prompted."
        exit 1
      fi
      ;;
    *)
      echo "Unsupported OS for git installation: $OS"
      exit 1
      ;;
  esac

  echo "Git installed successfully."
}

# Install git if not already installed
if ! command -v git &>/dev/null; then
  install_git
else
  echo "Git is already installed."
fi

# Clone the repository if it doesn't exist
if [ ! -d "$TARGET_DIR" ]; then
  echo "Cloning setup scripts repository..."
  git clone "$REPO_URL" "$TARGET_DIR"
else
  echo "Repository already exists at $TARGET_DIR. Pulling latest changes..."
  cd "$TARGET_DIR"
  git fetch origin                                                                                   1 ↵
  git reset --hard origin/main
  git pull origin main
fi

# Run the main install script
cd "$TARGET_DIR"
chmod +x install.sh
echo "Bootstrapping complete. Running main install script..."
./install.sh
