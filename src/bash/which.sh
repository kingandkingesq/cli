#!/usr/bin/env CLI_TOOL=cli bash-cli-part

CLI_IMPORT=(
    "cli path get-info"
)

cli::bash::which::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Search PATH for an executable file.

Description
    Argument \$1 is the name of the variable to write the discovered path.
    Argument \$2 is the name of the executable for which to search.

    The discovred path, if any, is stored in the REPLY variable.
    The probed path, if any, are stored in MAPFILE.

    Returns success if an executable is found, otherwise fails.

Examples
    ${CLI_COMMAND[@]} -- bash
EOF
}

cli::bash::which() {
    MAPFILE=()

    local NAME="$1"
    shift

    local IFS=:
    local -a DIRS=( ${PATH} )

    for dir in "${DIRS[@]}"; do
        local PROBE="${dir}/${NAME}"
        MAPFILE+=( "${PROBE}" )
        cli::path::get_info "${PROBE}"

        if ${REPLY_CLI_PATH_IS_EXECUTABLE}; then
            REPLY="${PROBE}"
            return 0
        fi
    done

    return 1
}

cli::bash::which::self_test() {
    diff <(which bash) <(${CLI_COMMAND[@]} ---reply bash) || cli::assert
    ! ${CLI_COMMAND[@]} -- does_not_exist || cli::assert
}
