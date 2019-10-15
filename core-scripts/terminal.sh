#!/usr/bin/env bash

line() {
    echo "${BLUE}==>${BOLD}${WHITE} $@${RESET}"
}

indent() {
    echo "${BOLD}    $@${RESET}"
}

warning() {
    echo "${YELLOW}Warning:${RESET} $*"
}

error() {
    echo "${RED}Error:${RESET} $*"
}
