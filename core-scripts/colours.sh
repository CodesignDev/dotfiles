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

INITED_COLOURS=false
init_colours() {
    if [ ! "$INITED_COLOURS" = true ]; then
        init_blank_colours

        if [ -t 1 ]; then
            init_terminal_colours
        fi
        INITED_COLOURS=true
    fi
}