setup: install_basics set_terminal install_docker set_sdk

install_basics:
	sudo chmod +x basics.sh
	sudo ./basics.sh

install_docker:
	sudo chmod +x docker.sh
	sudo ./docker.sh

set_terminal:
	sudo chmod +x term_env.sh term_emu.sh
	sudo ./term_env.sh
	sudo ./term_emu.sh

set_sdk:
	sudo chmod +x sdk.sh
	sudo ./sdk.sh
