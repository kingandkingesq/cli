#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli temp file

cli::temp::fifo::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Create a temporary fifo, set REPLY to its path, and register a trap to
    unlink the fifo upon subshell exit.

Description
    The first argument is the name of the variable to return the path to the
    temporary fifo. The default is REPLY.

    Upon exit a trap will run to delete the temporary fifo.
EOF
}

::cli::temp::fifo::inline() {
    ::cli::temp::file::inline "$@"
    rm -f "${REPLY}"
    mkfifo "${REPLY}"
}

cli::temp::fifo::self_test() {

    mapfile -t < <(
        # create a temp file
        ::cli::temp::fifo::inline
        [[ -p "${REPLY}" ]] || cli::assert
        echo "${REPLY}"

        # create a temp fifo to explicitly delete
        ::cli::temp::fifo::inline
        [[ -p "${REPLY}" ]] || cli::assert
        rm "${REPLY}"

        # create a temp file returned via a custom name
        ::cli::temp::fifo::inline
        local MY_REPLY="${REPLY}"
        [[ -p "${MY_REPLY}" ]] || cli::assert
        echo "${MY_REPLY}"
    )

    (( ${#MAPFILE[@]} == 2 )) || cli::assert
    [[ ! -a "${MAPFILE[0]}" ]] || cli::assert
    [[ ! -a "${MAPFILE[1]}" ]] || cli::assert
}
