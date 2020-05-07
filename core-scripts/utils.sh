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
