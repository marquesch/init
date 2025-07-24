SHELL := /bin/bash
SHELLFLAGS := -c -i

setup: install_dependencies set_terminal install_docker install_basics setup_nvim dotfiles set_bg_image set_aliases

install_dependencies:
	./dependencies.sh

install_basics:
	./basics.sh

install_docker:
	./docker.sh

set_terminal:
	./term_env.sh
	./term_emu.sh

dotfiles:
	./dotfiles.sh

setup_nvim:
	./setup_nvim.sh

gnome_set_dark_mode:
	gsettings set org.gnome.desktop.interface color-scheme prefer-dark

gnome_set_bg_image:
	mkdir -p ${HOME}/.config/ubuntu
	wget ${file_url} -O ${HOME}/.config/ubuntu/bg
	gsettings set org.gnome.desktop.background picture-uri file:///${HOME}/.config/ubuntu/bg
	gsettings set org.gnome.desktop.background picture-uri-dark file:///${HOME}/.config/ubuntu/bg

set_aliases:
	mkdir -p ${HOME}/.oh_my_zsh/custom
	wget https://raw.githubusercontent.com/marquesch/files/refs/heads/master/aliases.zsh -O ${HOME}/.oh_my_zsh/custom/aliases.zsh

