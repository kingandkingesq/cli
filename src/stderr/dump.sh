#!/usr/bin/env CLI_NAME=cli bash-cli-part
CLI_IMPORT=(
    "cli stderr cat"
    "cli process signal"
)

cli::stderr::dump::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Aquire exclusive stderr lock, copy stdin to stderr, and exit.

Description
    Stdin is copied to a temporary log file then the lock is taken and the file is
    copied to stderr. If the lock were taken and then stdin were copied to stdout a
    deadlock would happen if the generator of stdin aquired the lock. Copying the
    content to the temp file prevents that deadlock.  
EOF
}

cli::stderr::dump() {

    # copy stdin to stderr
    cli::stderr::cat

    # issue control-c
    cli::process::signal
}

cli::stderr::dump::self_test() {

    if (( $# > 0 )); then
        eval "$1"
        echo 'NO CTRL-C' >&2
    else
        test() {
            set -m
            if ${CLI_COMMAND[@]} --self-test -- "$@" 2>&1 1> /dev/null; then exit 1; fi 
        }

        diff <(test "echo 'LOG AND CTRL-C' | cli::stderr::dump") \
            <(echo "LOG AND CTRL-C") || cli::assert
    fi
}
