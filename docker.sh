#!/bin/bash

# --- Configuration ---
DOCKER_VERSION_STRING="latest" # You can specify a version like "5:24.0.5-1~ubuntu.22.04~jammy"
USERNAME=$(whoami)

# --- Functions ---

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

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root or with sudo."
    fi
}

install_ubuntu_docker() {
    log_info "Installing Docker on Ubuntu..."

    log_info "Updating apt package index and installing dependencies..."
    sudo apt update || log_error "Failed to update apt."

    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        sudo apt remove $pkg
    done

    sudo apt install -y ca-certificates curl gnupg lsb-release || log_error "Failed to install dependencies."

    log_info "Adding Docker's official GPG key..."
    sudo install -m 0755 -d /etc/apt/keyrings || log_error "Failed to create /etc/apt/keyrings directory."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyring/docker.asc || log_error "Failed to download and dearmor Docker GPG key."
    sudo chmod a+r /etc/apt/keyrings/docker.asc || log_error "Failed to set permissions on Docker GPG key."

    log_info "Setting up the Docker APT repository..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    log_info "Installing Docker Engine, containerd, and Docker Compose (plugin)..."
    sudo apt update || log_error "Failed to update apt after adding Docker repo."
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || log_error "Failed to install Docker components."
}

add_user_to_docker_group() {
    log_info "Checking if user '$USERNAME' is in the 'docker' group..."
    if id -nG "$USERNAME" | grep -qw "docker"; then
        log_success "User '$USERNAME' is already in the 'docker' group."
    else
        log_info "Adding user '$USERNAME' to the 'docker' group..."
        sudo usermod -aG docker "$USERNAME" || log_error "Failed to add user '$USERNAME' to the 'docker' group."
        log_warning "User '$USERNAME' has been added to the 'docker' group. You will need to log out and log back in (or reboot) for the changes to take full effect."
        log_success "User '$USERNAME' added to 'docker' group."
    fi
}

verify_docker_installation() {
    log_info "Verifying Docker installation..."
    if systemctl is-active --quiet docker; then
        log_success "Docker daemon is running."
    else
        log_error "Docker daemon is not running. Please check logs for issues: sudo systemctl status docker."
    fi

    log_info "Running a test Docker command (sudo might be needed initially if not logged in again)..."
    # This might fail immediately after adding user to group if user hasn't re-logged in
    # but the subsequent step will explain it.
    if docker run hello-world &> /dev/null; then
        log_success "Docker 'hello-world' ran successfully."
    else
        log_warning "Could not run 'docker run hello-world' immediately without sudo."
        log_warning "This is expected if you haven't logged out and back in after being added to the 'docker' group."
        log_warning "Please log out and log back in (or reboot) to ensure your user has the correct permissions to run Docker commands without 'sudo'."
    fi
}

# --- Main Script Execution ---
set -e # Exit immediately if a command exits with a non-zero status.
sudo -v # Refresh sudo timestamp

check_root

log_info "Starting Docker installation script for Ubuntu."

# Detect OS - only proceed if it's Ubuntu
if grep -qi "ubuntu" /etc/os-release; then
    install_ubuntu_docker
else
    log_error "Unsupported operating system. This script is designed for Ubuntu only. Exiting."
fi

add_user_to_docker_group

log_info "Enabling and starting Docker service..."
sudo systemctl enable docker || log_error "Failed to enable Docker service."
sudo systemctl start docker || log_error "Failed to start Docker service."
log_success "Docker service enabled and started."

verify_docker_installation

log_success "Docker installation complete on Ubuntu!"
log_warning "Remember to log out and log back in, or reboot your system, to ensure your user can run Docker commands without 'sudo'."
log_info "You can verify your user's permissions by running: 'docker run hello-world' after re-login."
