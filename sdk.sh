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

log_info "Starting asdf install using git"
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.15.0
echo '. "$home/.asdf/asdf.sh"' >> ~/.zshrc
echo "plugins+=(asdf)"

source ~/.zshrc

asdf plugin-add python https://github.com/asdf-community/asdf-python.git

asdf install python 3.6.15
asdf install python 3.8.20
