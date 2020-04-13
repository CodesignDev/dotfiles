#!/usr/bin/env bash

export IS_INTERACTIVE=0

# Test if the current shell is interactive (tests if STDIN is available)
is_interactive_shell() {
    is_interactive input && export IS_INTERACTIVE=1
}

is_interactive() {
    local MODE=$1
    local FILE_DESCRIPTOR=

    [[ "$MODE" == "input" ]] && FILE_DESCRIPTOR="0"
    [[ "$MODE" == "output" ]] && FILE_DESCRIPTOR="1"
    [[ "$MODE" == "error" ]] && FILE_DESCRIPTOR="2"

    [[ -t $FILE_DESCRIPTOR ]]
}

get_stdin() {
    if is_interactive input; then
        echo ""
        return
    fi

    echo $(</dev/stdin)
    return 0
}

is_shell_installed() {
    local REQUESTED_SHELL=$1

    cat /etc/shells | grep $QUIET_FLAG_GREP "$REQUESTED_SHELL$"
}
