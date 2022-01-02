#!/usr/bin/env CLI_NAME=cli bash-cli-part

cli::subshell::signal_group::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]}
    
Summary
    Issue control-c. 

Description
    Send signal $1 to all processes in the same process group id as the subshell.
    
    By defaul $1 is SIGINT which is equivilant to a control-c from the terminal.
EOF
}

cli::subshell::signal_group() {
    local SIGNAL=${1-'SIGINT'}
    read PID < <(ps -p ${BASHPID} -o pgid=)
    kill -${SIGNAL} -${PID}
}

cli::subshell::signal_group::self_test() {

    if (( $# > 0 )); then

        assert() {
            echo "ASSERT_FAILED ${BASHPID}" >&2
            if [[ "$1" != 'run' ]]; then ps -j >&2; fi
            cli::subshell::signal_group
            exit 1
        }

        echo workA ${BASHPID} >&2
        (
            echo workB ${BASHPID} >&2
            (
                echo workC ${BASHPID} >&2

                # assert
                { echo pipeA ${BASHPID} >&2; sleep 1; exit 2; } \
                    | { echo pipeB ${BASHPID} >&2; assert "$@"; exit 3; } \
                    | { echo pipeC ${BASHPID} >&2; }
                declare -p PIPESTATUS

                echo doneC ${BASHPID} >&2
            )
            echo doneB ${BASHPID} >&2
        )  
        echo doneA ${BASHPID} >&2
    
    else
        test() {
            set -m
            if ${CLI_COMMAND[@]} --self-test -- "$@" 2>&1; then exit 1; fi 
        }

        {
            read WORKA WORKA_PID
            [[ "${WORKA}" == 'workA' ]] || cli::assert

            read WORKB WORKB_PID
            [[ "${WORKB}" == 'workB' ]] || cli::assert
            
            read WORKC WORKC_PID
            [[ "${WORKC}" == 'workC' ]] || cli::assert

            { 
                read PIPEA PIPEA_PID
                [[ "${PIPEA}" == 'pipeA' ]] || cli::assert

                read PIPEB PIPEB_PID
                [[ "${PIPEB}" == 'pipeB' ]] || cli::assert
                
                read PIPEC PIPEC_PID
                [[ "${PIPEC}" == 'pipeC' ]] || cli::assert
                (( ${PIPEC_PID} == ${WORKC_PID} )) || cli::assert

            } 0< <({
                read PIPE0
                read PIPE1
                read PIPE2 
                printf '%s\n' "${PIPE0}" "${PIPE1}" "${PIPE2}"
            } | sort)
            
            read ASSERT ASSERT_PID
            [[ "${ASSERT}" == 'ASSERT_FAILED' ]] || cli::assert
            [[ "${ASSERT_PID}" == "${PIPEB_PID}" ]] || cli::assert

        } 0< <( test run )
    fi
}