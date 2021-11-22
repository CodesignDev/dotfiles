#!/usr/bin/env bash

CORE_HOOKS=(
    plugin_init
    init
    cleanup
)
ACTIVE_HOOKS=()
ACTIVE_HOOK_ACTIONS=()

# Are hooks disabled
DISABLED_HOOKS_GLOBAL=${DISABLE_HOOKS:-0}

hooks_init() {
    ACTIVE_HOOKS=()
    ACTIVE_HOOK_ACTIONS=()
}

hook() {
    local HOOK=$1
    local ACTION=$2

    # Register the hook if it doesn't already exist
    hook_exists $HOOK || hook_register $HOOK

    # Register the action
    hook_register_action $HOOK $ACTION
}

hook_run() {
    local HOOK=$1
    local ARGS=(${@:2})

    local ACTIONS

    # Are hooks disabled
    hooks_disabled $HOOK && return 0

    # Bail if the hook doesn't exist
    hook_exists $HOOK || return 1

    # Get the actions for this hook
    ACTIONS=($(hook_get_actions $HOOK))

    # Loop through each action
    for ACTION in ${ACTIONS[@]}; do

        # Skip if the action doesn't exist
        command_exists $ACTION || function_exists $ACTION || continue

        # Execute the action
        $ACTION ${ARGS[*]}
    done
    return 0
}

hook_exists() {
    local HOOK=$1

    # Check if the action is listed in the active hooks list
    array_is_valid_entry $HOOK ${ACTIVE_HOOKS[@]}
}

hook_is_core_hook() {
    local HOOK=$1

    # Is the hook listed in the core hooks list
    array_is_valid_entry $HOOK ${CORE_HOOKS[@]}
}

hooks_disabled() {
    local HOOK=$1

    # Are hooks disabled globally?
    [[ "$DISABLED_HOOKS_GLOBAL" == "1" ]] && return 0

    # Core hooks are never disabled
    hook_is_core_hook $HOOK && return 1

    # Otherwise is the internal flag set
    [[ "$DISABLE_HOOKS" == "1" ]] && return 0

    # Not disabled
    return 1
}

hook_register() {
    local HOOK=$1

    # If the hook already exists, bail
    array_is_valid_entry $HOOK ${ACTIVE_HOOKS[@]} && return

    # Add the hook to the list
    ACTIVE_HOOKS+=($HOOK)
}

hook_register_action() {
    local HOOK=$1
    local ACTION=$2

    # Bail if the hook doesn't exist
    hook_exists $HOOK || return 1

    # Add the action to the hook variable
    hook_add_action $HOOK $ACTION
}

hook_get_actions() {
    local HOOK=$1

    local FILTERED_ACTIONS

    # If the hook doesn't exist, bail
    hook_exists $HOOK || return 1

    # Filter the hook action list by our hook
    IFS=$'\n'; FILTERED_ACTIONS=($(printf '%s\n' "${ACTIVE_HOOK_ACTIONS[@]}" | sed "/^$HOOK\/\//"'!d'))

    # Remove the prefixes from the actions
    FILTERED_ACTIONS=($(echo "${FILTERED_ACTIONS[@]##*/}"))

    # Return the contents of the variable
    echo ${FILTERED_ACTIONS[@]}
    return 0
}

hook_add_action() {
    local HOOK=$1
    local ACTION=$2

    # Add the action to the list prefixed with the hook
    ACTIVE_HOOK_ACTIONS+=("$HOOK//$ACTION")
}
