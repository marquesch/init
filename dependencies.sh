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
install_common_dependencies() {
    log_info "Installing common system dependencies..."
    sudo apt update || log_error "Failed to update apt."
    sudo apt install -y curl wget gnupg apt-transport-https ca-certificates lsb-release software-properties-common build-essential || log_error "Failed to install common dependencies."
    log_success "Common dependencies installed."
}

install_common_dependencies

