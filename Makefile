SHELL := /bin/bash
SHELLFLAGS := -c -i

setup: install_dependencies set_terminal install_docker install_basics setup_vim dotfiles

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

setup_vim:
	./setup_vim.sh
