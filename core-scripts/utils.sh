#!/usr/bin/env bash

# Blank variables
export IS_INTERACTIVE=0

# Checks if a command exists on system
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Checks if a function exists
func_exists() {
    [[ -n "$(LC_ALL=C type -t $1)" ]] && [[ "$(LC_ALL=C type -t $1)" = function ]]
}

# Test if the current shell is interactive (tests if STDIN is available)
is_interactive_shell() {
    STDIN_FILE_DESCRIPTOR="0"
    [[ -t $STDIN_FILE_DESCRIPTOR ]] && export IS_INTERACTIVE=1
}

github_get_latest_release_version() {
    REPO=$1
    curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | jq -j '.tag_name'
}
