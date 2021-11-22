#!/usr/bin/env bash

# Some blank variables
DEBUG_ENABLED=
QUIET_FLAG=
QUIET_FLAG_APT=
QUIET_FLAG_GIT=
QUIET_FLAG_GREP=
QUIET_FLAG_UNZIP=

# Initializes debug mode
debug_init() {
    [[ "$1" == "--debug" || -o xtrace ]] && DEBUG_ENABLED=1
    debug_setup
}

# Sets up debug mode
debug_setup() {
    if [[ -n "$DEBUG_ENABLED" ]]; then
        set -x
    else
        debug_setup_quiet_flags
    fi
}

# Sets up quiet flags for various commands, only used when debug is disabled
debug_setup_quiet_flags() {
    QUIET_FLAG='-q'

    QUIET_FLAG_APT=$QUIET_FLAG
    QUIET_FLAG_GIT=$QUIET_FLAG
    QUIET_FLAG_GREP=$QUIET_FLAG
    QUIET_FLAG_UNZIP=$QUIET_FLAG
}

# Clear debug mode if set
debug_clear() {
    set +x
}

# Re-enables debug mode if it was enabled
debug_reset() {
    if [[ -n "$DEBUG_ENABLED" ]]; then
        set -x
    fi
}
