#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli core type get-info
cli::source cli core type unmodify

cli::core::type::unmodified::help() {
    cat << EOF | cli::core::type::help
Command
    ${CLI_COMMAND[@]}
    
Summary
    Return the unmodified type of a type.

Description
    Return a type without any modifiers. For example, the unmodified type of
    
        map_of map_of string

    is 

        string
EOF
}

::cli::core::type::unmodified::inline() {
    MAPFILE=( "$@" )

    while ::cli::core::type::unmodify::inline "${MAPFILE[@]}"; do
        :
    done

    REPLY=${MAPFILE}
}

cli::core::type::unmodified::self_test() {
    diff <( ${CLI_COMMAND[@]} ---reply boolean ) - <<< 'boolean' || cli::assert
    diff <( ${CLI_COMMAND[@]} ---reply map_of boolean ) - <<< 'boolean' || cli::assert
    diff <( ${CLI_COMMAND[@]} ---reply map_of map_of boolean ) - <<< 'boolean' || cli::assert
}
