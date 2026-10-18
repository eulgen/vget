# Autocomplétion Bash pour vget
_vget_completions() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    opts="init --init -v --video -a --audio -p --play -s --search -i --interactive --trim --sponsorblock --sub -b --batch -l --limit-rate -o --output --organize -F --formats -n --dry-run --simulate --check-deps --update -h --help -V --version"

    case "$prev" in
        -v|--video)
            local qualities="1080p 720p 480p 360p 240p 144p 4k best"
            # shellcheck disable=SC2207
            COMPREPLY=( $(compgen -W "$qualities" -- "$cur") )
            return 0
            ;;
        -a|--audio)
            local formats="mp3 flac m4a wav"
            # shellcheck disable=SC2207
            COMPREPLY=( $(compgen -W "$formats" -- "$cur") )
            return 0
            ;;
        -b|--batch)
            # shellcheck disable=SC2207
            COMPREPLY=( $(compgen -f -- "$cur") )
            return 0
            ;;
        -o|--output)
            # shellcheck disable=SC2207
            COMPREPLY=( $(compgen -d -- "$cur") )
            return 0
            ;;
        --sub)
            local langs="fr en es de it all"
            # shellcheck disable=SC2207
            COMPREPLY=( $(compgen -W "$langs" -- "$cur") )
            return 0
            ;;
    esac

    if [[ "$cur" =~ ^- ]]; then
        # shellcheck disable=SC2207
        COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
        return 0
    fi
}

complete -F _vget_completions vget
