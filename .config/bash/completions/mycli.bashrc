# Exemplo didático de programmable completion para o comando `mycli`.
#
# Como funciona:
#   - COMP_WORDS[COMP_CWORD] → palavra atual sob o cursor
#   - COMPREPLY              → array com as sugestões exibidas pelo bash
#   - compgen -W/-c/-f/-d    → gera candidatos (lista, comandos, arquivos, diretórios)

_mycli_commands="help init build test status version --help --verbose"

_mycli() {
    local current="${COMP_WORDS[COMP_CWORD]}"

    case "${COMP_WORDS[1]:-}" in
        init|build|test|status)
            mapfile -t COMPREPLY < <(compgen -W "--help --dry-run --verbose" -- "$current")
            ;;
        *)
            mapfile -t COMPREPLY < <(compgen -W "$_mycli_commands" -- "$current")
            ;;
    esac

    return 0
}

# Para completar arquivos/diretórios, troque compgen -W por compgen -f ou -d.
complete -F _mycli mycli
