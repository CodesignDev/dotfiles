#!/usr/bin/env bash

# Arch flags
export OS_ARCH=
export IS_I386=0
export IS_AMD64=0
export IS_ARM=0
export IS_ARM64=0

detect_arch() {

    # Get the arch
    OS_ARCH=$(uname -m)

    # Tweak some values
    case $OS_ARCH in
        armv5*) OS_ARCH="armv5";;
        armv6*) OS_ARCH="armv6";;
        armv7*) OS_ARCH="arm";;
        aarch64) OS_ARCH="arm64";;
        x86) OS_ARCH="386";;
        x86_64) OS_ARCH="amd64";;
        i686) OS_ARCH="386";;
        i386) OS_ARCH="386";;
    esac

    # Set up flags
    is_arch_i386 && export IS_I386=1
    is_arch_amd64 && export IS_AMD64=1
    is_arch_arm && export IS_ARM=1
    is_arch_arm64 && export IS_ARM64=1

    return 0
}

is_arch_i386() {
    [[ "$OS_ARCH" == "386" ]]
}

is_arch_amd64() {
    [[ "$OS_ARCH" == "amd64" ]]
}

is_arch_arm() {
    [[ $(echo $OS_ARCH | grep $QUIET_FLAG_GREP "arm") ]]
}

is_arch_arm64() {
    [[ "$OS_ARCH" == "arm64" ]]
}
