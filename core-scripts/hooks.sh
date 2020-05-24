#!/usr/bin/env bash

VALID_HOOKS=(
    'TODO' # Will be added at a later time
)
ACTIVE_HOOKS=()

hooks_init() {
    ACTIVE_HOOKS=()
}

hook() {
    local HOOK=$1
    local FUNCTION=$2
    local HOOK_FUNC=$1:$2

    [[ $(hook_already_exists $HOOK_FUNC) ]] && return 0

    if hook_is_valid_hook $HOOK; then
        ACTIVE_HOOKS+=($HOOK_FUNC)
        return 0
    fi
    return 0
}

hook_run() {
    local HOOK=$1
    local ARGS=(${@:2})

    [[ "$DISABLE_HOOKS" == "1" ]] && return 0

    local CURRENT_HOOK
    local CURRENT_FUNC

    for CURRENT_HOOK_FUNC in ${ACTIVE_HOOKS[@]}; do
        CURRENT_HOOK=$(echo $CURRENT_HOOK_FUNC | cut -f 1 -d :)
        CURRENT_FUNC=$(echo $CURRENT_HOOK_FUNC | cut -f 2 -d :)

        [[ "$CURRENT_HOOK" == "$HOOK" ]] && $CURRENT_FUNC ${ARGS[*]}
    done
    return 0
}

hook_is_valid_hook() {
    local HOOK=$1
    return 0

    for CURRENT_HOOK in ${VALID_HOOKS[@]}; do
        [[ "$CURRENT_HOOK" == "$HOOK" ]] && return 0
    done
    return 1
}

hook_already_exists() {
    local HOOK_FUNC=$1

    for CURRENT_ITEM in ${ACTIVE_HOOKS[@]}; do
        [[ "$CURRENT_ITEM" == "$HOOK_FUNC" ]] && return 0
    done
    return 1
}
