#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::process::tree::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Load the parent process of each process into an array.

Description
    Load the parent process of each process into an array MAP. A custom
    name for the array can be passed in as the first positional argument.
EOF
}

main() {
    ::cli::process::tree::inline "$@"
    declare -p MAP
}

::cli::process::tree::inline() {
    if [[ ! ${1-} ]]; then
        declare -Ag MAP=()
        set MAP
    fi

    local -n CLI_SUBSHELL_TREE_REF_ARRAY=$1

    while read pid ppid; do
        CLI_SUBSHELL_TREE_REF_ARRAY[${pid}]=${ppid}
    done < <(ps -o pid=,ppid=)
}

cli::process::tree::self_test() {
    cli::source cli-assert

    ::cli::process::tree::inline
    [[ "${MAP[$$]-}" ]] || cli::assert

    ( 
        ::cli::process::tree::inline
        [[ "${MAP[$BASHPID]-}" == "$$" ]] || cli::assert
    )
}
