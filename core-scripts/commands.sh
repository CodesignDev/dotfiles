#!/usr/bin/env bash

# Checks if a command exists on system
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Alternate name for command_exists
cmd_exists() {
    command_exists $@
}

# Get a path to a command
get_command_path() {
    local COMMAND=$1
    if command_exists $COMMAND; then
        command -v "$1" 2>/dev/null
    else
        echo \\$COMMAND
    fi
}

# Checks if a function exists
function_exists() {
    [[ -n "$(LC_ALL=C type -t $1)" ]] && [[ "$(LC_ALL=C type -t $1)" = function ]]
}

# Alternate name for function_exists
func_exists() {
    function_exists $@
}
