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
	sudo apt install -y apt-transport-https build-essential bzip2 curl ca-certificates \
		git gnupg libbz2-dev libffi-dev liblzma-dev libncursesw5-dev libreadline-dev \
		libsqlite3-dev libssl-dev libxml2-dev libxmlsec1-dev lsb-release libasound2-dev libdbus-1-dev make \
		pkg-config software-properties-common tk-dev wget xz-utils zlib1g-dev universal-ctags libpq-dev || log_error "Failed to install common dependencies."
	log_success "Common dependencies installed."
}

install_common_dependencies
