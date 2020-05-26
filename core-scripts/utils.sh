#!/usr/bin/env bash

# Wrapper around readlink that works on both linux and osx
resolve_symlink() {
    local ARGS=($@)

    # readlink executable
    local READLINK_FUNC=readlink

    # For osx users, use greadlink from coreutils
    is_macos && READLINK_FUNC=greadlink

    # Execute the call
    $READLINK_FUNC ${ARGS[@]}
}

# Small utility function to check if a value is in a list of values
array_is_valid_entry() {
    local VALUE=$1
    local ENTRIES=(${@:2})

    for ENTRY in ${ENTRIES[@]}; do
        [[ "$ENTRY" == "$VALUE" ]] && return 0
    done
    return 1
}
