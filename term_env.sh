#!/bin/bash

# --- Configuration ---
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}" # Ensure ZSH_CUSTOM is set if not already

# --- Helper Functions for Logging ---
log_info() {
    echo -e "\n\033[0;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\n\033[0;32m[SUCCESS]\033[0m $1"
}

log_warning() {
    echo -e "\n\033[0;33m[WARNING]\033[0m $1"
}

log_error() {
    echo -e "\n\033[0;31m[ERROR]\033[0m $1" >&2
    exit 1
}

# --- Script Start ---
set -e # Exit immediately if a command exits with a non-zero status.
sudo -v # Refresh sudo timestamp

log_info "Starting development environment setup script."

# --- Install Homebrew ---
log_info "Attempting to install Homebrew..."
if command -v brew &> /dev/null; then
    log_info "Homebrew is already installed. Skipping installation."
else
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || log_error "Failed to install Homebrew."

    # Add Homebrew to PATH for the current session and persistent configuration
    log_info "Adding Homebrew to shell environment..."
    if [ -d "$HOME/.linuxbrew" ]; then
        eval "$($HOME/.linuxbrew/bin/brew shellenv)"
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
    elif [ -d "/home/linuxbrew/.linuxbrew" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
    else
        # Fallback for systems where brew might install to /usr/local
        eval "$($(brew --prefix)/bin/brew shellenv)"
        echo 'eval "$($(brew --prefix)/bin/brew shellenv)"' >> ~/.profile
        echo 'eval "$($(brew --prefix)/bin/brew shellenv)"' >> ~/.zshrc
    fi
    log_success "Homebrew installed and configured."
fi


# --- Install Zsh ---
log_info "Attempting to install Zsh..."
if command -v zsh &> /dev/null; then
    log_info "Zsh is already installed."
else
    log_info "Installing Zsh..."
    sudo apt update && sudo apt install -y zsh || log_error "Failed to install Zsh."
    log_success "Zsh installed."
fi

log_info "Setting Zsh as default shell..."
if [ "$(basename "$SHELL")" = "zsh" ]; then
    log_info "Zsh is already the default shell for the current user."
else
    chsh -s "$(which zsh)" || log_error "Failed to set Zsh as default shell."
    log_warning "Zsh set as default shell. Please log out and log back in (or reboot) for this change to take effect."
    log_success "Zsh set as default shell."
fi

# --- Install Oh My Zsh ---
log_info "Attempting to install Oh My Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    log_info "Oh My Zsh is already installed. Skipping installation."
else
    log_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || log_error "Failed to install Oh My Zsh."
    log_success "Oh My Zsh installed."
fi

# --- Install Zsh Plugins and Theme ---
log_info "Installing Zsh plugins and Powerlevel10k theme..."

# Ensure ZSH_CUSTOM exists
mkdir -p "${ZSH_CUSTOM}/plugins" || log_error "Failed to create ZSH_CUSTOM plugins directory."
mkdir -p "${ZSH_CUSTOM}/themes" || log_error "Failed to create ZSH_CUSTOM themes directory."

# zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
    log_info "Cloning zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" || log_error "Failed to clone zsh-autosuggestions."
else
    log_info "zsh-autosuggestions already exists. Skipping clone."
fi

# zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
    log_info "Cloning zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" || log_error "Failed to clone zsh-syntax-highlighting."
else
    log_info "zsh-syntax-highlighting already exists. Skipping clone."
fi

# zsh-you-should-use
if [ ! -d "${ZSH_CUSTOM}/plugins/you-should-use" ]; then
    log_info "Cloning zsh-you-should-use..."
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "${ZSH_CUSTOM}/plugins/you-should-use" || log_error "Failed to clone zsh-you-should-use."
else
    log_info "zsh-you-should-use already exists. Skipping clone."
fi

# zsh-bat
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-bat" ]; then
    log_info "Cloning zsh-bat..."
    git clone https://github.com/fdellwing/zsh-bat.git "${ZSH_CUSTOM}/plugins/zsh-bat" || log_error "Failed to clone zsh-bat."
else
    log_info "zsh-bat already exists. Skipping clone."
fi

# powerlevel10k
if [ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
    log_info "Cloning Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k" || log_error "Failed to clone Powerlevel10k."
else
    log_info "Powerlevel10k theme already exists. Skipping clone."
fi

# Copy .p10k.zsh config (assuming it's in the same directory as this script)
if [ -f ".p10k.zsh" ]; then
    log_info "Copying .p10k.zsh configuration file..."
    cp .p10k.zsh "$HOME/.p10k.zsh" || log_error "Failed to copy .p10k.zsh."
else
    log_warning "'.p10k.zsh' not found in the script's directory. Powerlevel10k will start its configuration wizard on first Zsh launch."
fi


# Configure .zshrc
log_info "Updating ~/.zshrc with theme and plugins..."

# Set ZSH_THEME
if ! grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' "$HOME/.zshrc"; then
    sed -i 's/^ZSH_THEME="[^"]*"$/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
    if ! grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' "$HOME/.zshrc"; then
        echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$HOME/.zshrc"
    fi
else
    log_info "ZSH_THEME already set to powerlevel10k."
fi

# Source .p10k.zsh
if ! grep -q '\[\[ ! -f ~/.p10k.zsh \]\] \|\| source ~/.p10k.zsh' "$HOME/.zshrc"; then
    echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >> "$HOME/.zshrc"
else
    log_info "Powerlevel10k source line already exists in ~/.zshrc."
fi

# Set plugins
NEW_PLUGINS="git zsh-autosuggestions zsh-syntax-highlighting you-should-use zsh-bat"
if grep -q "plugins=(" "$HOME/.zshrc"; then
    # Replace existing plugins line
    sed -i "s/^plugins=(.*)$/plugins=($NEW_PLUGINS)/" "$HOME/.zshrc"
else
    # Add plugins line if not found
    echo "plugins=($NEW_PLUGINS)" >> "$HOME/.zshrc"
fi
log_success "Zsh plugins and theme configured in ~/.zshrc."

log_success "Development environment setup complete!"
log_warning "Please remember to log out and log back in, or reboot, for Zsh and Homebrew changes to take full effect."
