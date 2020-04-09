#!/usr/bin/env bash

escape() {
    printf '\033[%sm' $1
}

init_blank_colours() {
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    WHITE=""
    BOLD=""
    UNDERLINE=""
    RESET=""
}

init_terminal_colours() {
    RED=$(escape '31')
    GREEN=$(escape '32')
    YELLOW=$(escape '33')
    BLUE=$(escape '34')
    WHITE=$(escape '97')
    BOLD=$(escape '1')
    UNDERLINE=$(escape '4')
    RESET=$(escape '0')
}

INITED_COLOURS=0
init_colours() {
    if [ "$INITED_COLOURS" == "1" ]; then
        return 0
    fi
    init_blank_colours

    if is_interactive output; then
        init_terminal_colours
    fi
    INITED_COLOURS=1
}
