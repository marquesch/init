#!/bin/bash

nvim_plugins_folder="$HOME/.config/nvim/pack/plugins/start"

install_fzf_plugin() {
    echo "Trying to install fzf plugin via git..."
    if [ -d "$vim_plugins_folder/fzf.vim" ]; then
        echo "Plugin already installed!"
        return 0
    fi
    git clone --depth 1 https://github.com/junegunn/fzf.vim "$nvim_plugins_folder/fzf.vim"

    echo "Successfully installed fzf vim plugin!"
}

echo "Trying to create plugins folder..."
mkdir -p $nvim_plugins_folder

install_fzf_plugin

