SHELL := /bin/bash
SHELLFLAGS := -c -i

setup: install_basics set_terminal install_docker dotfiles

install_basics:
	./basics.sh

install_docker:
	./docker.sh

set_terminal:
	./term_env.sh
	./term_emu.sh

dotfiles:
	./dotfiles.sh

