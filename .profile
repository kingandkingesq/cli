set +m
shopt -s lastpipe

REPO_DIR=$(cd $(dirname ${BASH_SOURCE}); pwd)
GIT_DIR=$(cd "${REPO_DIR}/.."; pwd)

# basic command prompt
export PS1='$(pwd)/ $ '

if [[ -z "${PATH_ORIG}" ]]; then
    PATH_ORIG=$PATH
fi

PATH="${PATH_ORIG}"
PATH+=":${GIT_DIR}/bin"
PATH+=":${GIT_DIR}/cli"
PATH+=":${GIT_DIR}/cli/src"
PATH+=":${GIT_DIR}/cli_assert"
PATH+=":${GIT_DIR}/cli_util"
PATH+=":${GIT_DIR}/cli_emit"
PATH+=":${GIT_DIR}/cli_math"
PATH+=":${GIT_DIR}/cli_constant"
PATH+=":${GIT_DIR}/integrate"
PATH+=":${GIT_DIR}/vscs"
PATH+=":${GIT_DIR}/azx"

alias re="source ${REPO_DIR}/.profile"
alias packcli="time cli pack --dir ${REPO_DIR}/src --name cli --output-dir ${GIT_DIR}/bin"
alias enable_cache="declare +x CLI_LOADER_DISABLE_CACHE=1"
alias disable_cache="declare -x CLI_LOADER_DISABLE_CACHE=1"
alias tst="cli .group --self-test"

# rvm madness; rvm redefines cd and Fs it all up
unset MY_RUBY_HOME
unset cd
