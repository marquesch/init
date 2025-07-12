#!/bash/bin

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

source ~/.zshrc

log_info "Adding python asdf plugin..."
asdf plugin-add python https://github.com/asdf-community/asdf-python.git

log_info "Installing python 3.6.15 and 3.8.20"
asdf install python 3.6.15
asdf install python 3.8.20
