#!/bin/bash

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
set -e  # Exit immediately if a command exits with a non-zero status.
sudo -v # Refresh sudo timestamp

log_info "Attempting to install alacritty..."
if command -v alacritty &>/dev/null; then
    log_info "Alacritty already installed. Skipping..."
else
    log_info "Installing alacritty..."
    git clone https://github.com/alacritty/alacritty.git
    cd alacritty
    cargo build --release
    sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
    sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
    sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
    sudo desktop-file-install extra/linux/Alacritty.desktop
    sudo update-desktop-database
    sudo mkdir -p /usr/local/share/man/man1
    sudo mkdir -p /usr/local/share/man/man5
    scdoc < extra/man/alacritty.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
    scdoc < extra/man/alacritty-msg.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
    scdoc < extra/man/alacritty.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty.5.gz > /dev/null
    scdoc < extra/man/alacritty-bindings.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty-bindings.5.gz > /dev/null
    cp extra/completions/_alacritty ${ZDOTDIR:-~}/.zsh_functions/_alacritty
    log_success "Alacritty installed"
fi

# --- Install Meslo Nerd Font ---
log_info "Attempting to install MesloLGS Nerd Font Mono..."
if [ ! -f "$HOME/.fonts/MesloLGSNerdFontMono-Regular.ttf" ]; then
	wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip
	mkdir -p "$HOME/.fonts"
	unzip Meslo.zip -d "$HOME/.fonts"
	rm Meslo.zip
	log_success "Successfully installed MesloLGS Mono Nerd Font"
else
	log_info "MesloLGS Nerd Font Mono already installed. Skipping..."
fi

log_info "Attempting to install tmux"
if command -v tmux &>/dev/null; then
    log_info "tmux already installed. Skipping..."
else
    sudo apt update && sudo apt install -y tmux
    log_success "tmux successfully installed"
fi

log_info "Attempting to install tmux package manager"
if [ -d "$HOME/.tmux/ "]; then
    log_info "TPM already installed. Skipping..."
else
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    log_success "Succesfully installed TPM..."

log_success "WezTerm installation and configuration complete!"
log_warning "You may need to restart your terminal or session for changes (especially default terminal) to take full effect."
