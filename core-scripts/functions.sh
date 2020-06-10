#!/usr/bin/env bash

# Small function to check if a value is in a list of values
array_is_valid_entry() {
    local VALUE=$1
    local ENTRIES=(${@:2})

    for ENTRY in ${ENTRIES[@]}; do
        [[ "$ENTRY" == "$VALUE" ]] && return 0
    done
    return 1
}
