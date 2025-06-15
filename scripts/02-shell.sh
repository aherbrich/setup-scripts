#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/log.sh"

if [[ -z "${OS_NAME:-}" ]]; then
error "OS_NAME is not set. Please call this script only from ./install.sh or ensure OS detection is done first."
exit 1
else
info "Using detected OS: $OS_NAME"
fi

ZSH_CUSTOM="${HOME}/.oh-my-zsh/custom"

install_zsh() {
    info "Checking if zsh is installed..."
    if command -v zsh >/dev/null 2>&1; then
        info "zsh is already installed."
    else
        info "zsh not found. Installing..."
        case "$OS_NAME" in
        macos) brew install zsh ;;
        amazon-linux) sudo dnf install -y zsh || sudo yum install -y zsh ;;
        *) error "Unsupported OS for zsh installation: $OS_NAME"; exit 1 ;;
        esac
    fi
}

install_oh_my_zsh() {
    if [[ -d "${HOME}/.oh-my-zsh" ]]; then
        info "Oh My Zsh already installed."
    else
        info "Installing Oh My Zsh..."
        # Default install: creates .zshrc and runs interactively if RUNZSH not set
        RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
}

install_plugins() {
    info "Installing zsh-users plugins..."

    local plugins_to_install=("zsh-autosuggestions" "zsh-syntax-highlighting")
    local plugin_url_prefix="https://github.com/zsh-users"
    local plugin_dir

    mkdir -p "${ZSH_CUSTOM}/plugins"

    for plugin in "${plugins_to_install[@]}"; do
        plugin_dir="${ZSH_CUSTOM}/plugins/${plugin}"
        if [[ ! -d "$plugin_dir" ]]; then
        git clone "${plugin_url_prefix}/${plugin}.git" "$plugin_dir"
        info "Installed plugin: $plugin"
        else
        info "Plugin already installed: $plugin"
        fi
    done

    # Now update ~/.zshrc plugins line
    local zshrc="$HOME/.zshrc"
    if [[ ! -f "$zshrc" ]]; then
        warn "$zshrc does not exist. Please start a new shell or run 'ohmyzsh' installer first."
        return
    fi

    # Extract current plugins line
    if grep -q '^plugins=' "$zshrc"; then
        # Get current plugins (strip 'plugins=(' and ')', handle spaces)
        local current_plugins
        current_plugins=$(sed -n 's/^plugins=(\(.*\))/\1/p' "$zshrc" | tr -d '()' | tr ' ' '\n' | sort -u)

        # Combine current + new plugins, removing duplicates
        local all_plugins
        all_plugins=$(echo -e "${current_plugins}\n${plugins_to_install[*]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
        all_plugins="${all_plugins%" "}" # trim trailing space

        # Replace plugins= line with updated plugins list
        sed -i.bak -E "s/^plugins=\(.*\)/plugins=(${all_plugins})/" "$zshrc"
        info "Updated plugins line in $zshrc: plugins=(${all_plugins})"
    else
        # No plugins line — add it near the top (after any initial comments)
        sed -i.bak '1i plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' "$zshrc"
        info "Added plugins line to $zshrc"
    fi
}

set_default_shell() {
    local current_shell
    local zsh_path

    zsh_path="$(command -v zsh)"

    # Detect OS and get the real default shell from system user info
    case "$OS_NAME" in
        macos)
        current_shell=$(dscl . -read /Users/"$USER" UserShell 2>/dev/null | awk '{print $2}')
        ;;
        amazon-linux|ubuntu|debian|fedora|arch)
        current_shell=$(getent passwd "$USER" | cut -d: -f7)
        ;;
        *)
        # Fallback to $SHELL env var if unknown OS
        current_shell="$SHELL"
        ;;
    esac

    if [[ "$current_shell" == "$zsh_path" ]]; then
        info "Default shell is already set to zsh ($zsh_path)."
        return
    fi

    info "Changing default shell to zsh ($zsh_path)..."

    if ! grep -q "^$zsh_path$" /etc/shells; then
        warn "zsh ($zsh_path) is not listed in /etc/shells. Attempting to add it..."
        if sudo "$SHELL" -c "echo '$zsh_path' >> /etc/shells"; then
        info "Added $zsh_path to /etc/shells"
        else
        error "Failed to add $zsh_path to /etc/shells. Default shell change may fail."
        fi
    fi

    if chsh -s "$zsh_path"; then
        success "Default shell changed to zsh."
        info "Please restart your terminal or log out/in to apply the new shell."
    else
        error "Failed to change default shell to zsh. You might need to do this manually."
    fi
}

main() {
    install_zsh
    install_oh_my_zsh
    install_plugins
    set_default_shell
    success "Shell setup completed."
}

main "$@"

