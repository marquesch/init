#!/bin/bash

vim_plugins_folder="$HOME/.vim/pack/plugins/start"

install_fzf_plugin() {
    echo "Trying to install fzf plugin via git..."
    if [ -d "$vim_plugins_folder/fzf.vim" ]; then
        echo "Plugin already installed!"
        return 0
    fi
    git clone --depth 1 https://github.com/junegunn/fzf.vim "$vim_plugins_folder/fzf.vim"

    echo "Successfully installed fzf vim plugin!"
}

echo "Trying to create plugins folder..."
mkdir -p $vim_plugins_folder

install_fzf_plugin

