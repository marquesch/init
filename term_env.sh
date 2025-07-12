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


log_success "Set terminal environment successfully!"

