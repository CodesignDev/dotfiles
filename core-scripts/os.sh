#!/usr/bin/env bash

# OS flags
export OS=
export MACOS=0
export LINUX=0
export WINDOWS=0
export WSL_VERSION=0

# Detect the OS
detect_os() {

    # Get the os details
    OS_KERNEL_NAME=$(uname -s)
    OS_KERNEL_RELEASE=$(uname -r)

    # Extract base OS
    [[ "$OS_KERNEL_NAME" == "Darwin" ]] && export MACOS=1 && export OS="darwin"
    [[ "$OS_KERNEL_NAME" == "Linux" ]] && export LINUX=1 && export OS="linux"
    [[ "$OS_KERNEL_NAME" == *"_NT"* ]] && export WINDOWS=1 && export OS="windows"

    # Detect WSL runtime version
    [[ "$OS_KERNEL_RELEASE" == *"microsoft"* ]] && export WSL_VERSION=1
    [[ "$OS_KERNEL_RELEASE" == *"microsoft-standard"* ]] && export WSL_VERSION=2

    # Set some flags
    (is_macos || is_linux) && export UNIX=1

    return 0
}

is_macos() {
    [[ "$MACOS" == "1" ]]
}

is_linux() {
    [[ "$LINUX" == "1" ]]
}

is_windows() {
    [[ "$WINDOWS" == "1" ]]
}

is_unix() {
    is_macos || is_linux
}

is_wsl() {
    is_linux && [[ $WSL_VERSION -gt 0 ]]
}

is_wsl1() {
    is_linux && [[ "$WSL_VERSION" == "1" ]]
}

is_wsl2() {
    is_linux && [[ "$WSL_VERSION" == "2" ]]
}
