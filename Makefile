init: setup_terminal setup_sdk setup_docker install_apps

setup_terminal:
	./term_env.sh
	./term_emu.sh
	./fzf.sh

setup_sdk:
	./sdk.sh

setup_docker:
	./docker.sh

install_apps:
	./basics.sh

