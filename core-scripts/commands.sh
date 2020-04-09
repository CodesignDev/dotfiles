#!/usr/bin/env bash

# Checks if a command exists on system
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Checks if a function exists
func_exists() {
    [[ -n "$(LC_ALL=C type -t $1)" ]] && [[ "$(LC_ALL=C type -t $1)" = function ]]
}
