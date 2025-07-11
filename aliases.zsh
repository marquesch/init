openrep() {
	remote_url=$(git remote get-url origin 2>/dev/null)

	if [ $? -ne 0]; then
		echo "Error: Not a git repo or no origin remote found"
		exit 1
	fi

	if [[ "$remote_url" = git@* ]]; then
		url=${remote_url#git@}
		url=${url/:/\/}
		url="https://$url"
		url=${url%.git}
	else
		url=${remote_url%.git}
	fi

	if command -v brave-browser &> /dev/null; then
		brave-browser "$url"
	elif command -v brave &> /dev/null; then
		brave "$url"
	else
		echo "Error: Brave browser not found"
		exit 1
	fi
}

dclogs() {
	docker compose logs -f --tail 1000 "$@"
}

dcbash() {
	docker compose exec "$@" bash
}

dcrestlogs() {
    if [[ -n "$1" ]]; then
        docker compose restart "$@" && docker compose logs -f --tail 1000 "$@"
    fi
}

dcupd() {
	docker compose up "$@" -d
}

dcd() {
	docker compose down "$@"
}

dcrest() {
	docker compose restart "$@"
}

dcex() {
	docker compose exec "$1" "$2"
}

dcrun() {
	docker compose run "$1" "$2"
}

# completion dc services
_dcaliases_complete() {
    local services
    services=$(docker compose ps --services --status running)
    COMPREPLY=($(compgen -W "$services" -- "${COMP_WORDS[COMP_CWORD]}"))
}

# completion
complete -F _dcaliases_complete dcrestlogs
complete -F _dcaliases_complete dcbash
complete -F _dcaliases_complete dclogs
complete -F _dcaliases_complete dcrest

alias dcps="docker compose ps"
alias rmvbranches="git fetch -p && git branch -vv | grep ': gone]' | awk '{print \$1}' | xargs -r -I {} git branch -d '{}'"
alias openrep="zsh ~/Documents/scripts/open-git-url.sh"
alias dstopall="docker ps -q | xargs docker stop"
