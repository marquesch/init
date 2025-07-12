#!/bin/bash

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


log_info "Cloning dotfiles repo..."
git clone git@github.com:marquesch/dotfiles.git "$HOME/dotfiles"

cd "$HOME/dotfiles"
sudo chmod +x lndotfiles.sh
./lndotfiles.sh

if [ "$?" -eq 0 ]; then
    log_success "Symlink dotfiles successfully!"
else
    log_error "Error symlinking dotfiles!" 
fi

