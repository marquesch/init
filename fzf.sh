#!/bin/bash
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Please install it first:"
    exit 1
fi

brew install fzf

echo "source <(fzf --zsh)" >> ~/.zsrhc
