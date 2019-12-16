#!/usr/bin/env bash

# OS flags
export OS=
export MACOS=0
export LINUX=0
export WSL=0
export WINDOWS=0

# Detect the OS
detect_os() {
    is_macos && export MACOS=1 && export UNIX=1
    is_linux && export LINUX=1 && export UNIX=1
    is_wsl && export WSL=1
    is_windows && export WINDOWS=1

    is_macos && export OS="macos"
    is_linux && export OS="linux"
    is_windows && export OS="windows"

    return 0
}

is_macos() {
    [[ $(uname -s) == "Darwin" ]]
}

is_linux() {
    [[ $(uname -s) == "Linux" ]]
}

is_wsl() {
    is_linux && [[ $(uname -r | grep $QUIET_FLAG_GREP "Microsoft") ]]
}

is_windows() {
    [[ $(uname -s | grep $QUIET_FLAG_GREP "_NT-") ]]
}
