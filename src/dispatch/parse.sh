#!/usr/bin/env CLI_NAME=cli bash-cli-part
cli::source cli core variable get-info
cli::source cli args tokenize
cli::source cli args parse
cli::source cli args resolve
cli::source cli args verify

cli::dispatch::parse::help() {
    cat << EOF
Command
    ${CLI_COMMAND[@]} 

Summary    
    Parses command line arguments.

Declare
    ARG_SCOPE is the name of the scope.
    CLI_META is the name of the metadata for the arguments.

    \$1 - \$n are command line arguments.

    REPLY_CLI_PARSE_ARGS is the parsed arguments.

    REPLY is the metadata for the argument group.
EOF
}

::cli::dispatch::parse::inline() {
    [[ "${ARG_SCOPE-}" ]] || cli::assert 'Missing scope.'

    # somehow the metadata should have been declared
    ::cli::core::variable::get_info::inline ${CLI_META} || cli::assert "Missing metadata."
    ${REPLY_CLI_CORE_TYPE_IS_USER_DEFINED} || cli::assert "Metadata not user defined type."

    # tokenize
    ::cli::args::tokenize::inline "$@"

    # parse
    ARG_META_ALIASES=${CLI_META}_ALIAS \
        ::cli::args::parse::inline REPLY_CLI_ARGS_TOKENS

    # resolve
    ARG_META_GROUPS=${CLI_META}_GROUP \
        ::cli::args::resolve::inline REPLY_CLI_PARSE_ARGS
    local CLI_META_GROUP=${REPLY}

    # verify
    ARG_META_GROUP=${CLI_META_GROUP} \
        ::cli::args::verify::inline REPLY_CLI_PARSE_ARGS

    REPLY=${CLI_META_GROUP}
}

cli::dispatch::parse::self_test() {
    return
}   
