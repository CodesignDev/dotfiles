#!/usr/bin/env bash

CORE_HOOKS=(
    plugin_init
    init
    cleanup
)
ACTIVE_HOOKS=()

# Are hooks disabled
DISABLED_HOOKS_GLOBAL=${DISABLE_HOOKS:-0}

hooks_init() {
    local HOOK_VAR_NAME

    if [[ ${#ACTIVE_HOOKS[@]} -gt 0 ]]; then
        for HOOK in ${ACTIVE_HOOKS[@]}; do
            HOOK_VAR_NAME=$(hook_get_var_name $HOOK)
            unset $HOOK_VAR_NAME
        done
    fi

    ACTIVE_HOOKS=()
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
    [[ "$DISABLE_HOOKS_GLOBAL" == "1" ]] && return 0

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

    # Create the variable that holds the actions
    hook_register_action_array $HOOK
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

    # Get the variable name for the hook
    local HOOK_VAR=$(hook_get_var_name $HOOK)

    # If the hook doesn't exist, bail
    hook_exists $HOOK || return 1

    # Check if the variable exists
    hook_var_exists $HOOK_VAR || return 1

    # Return the contents of the variable
    echo ${!HOOK_VAR}
    return 0
}

hook_get_var_name() {
    local HOOK_NAME=$1
    local HOOK_PREFIX="DOTFILES_HOOK_VAR"
    local HOOK

    HOOK_NAME=$(echo $HOOK_NAME | tr '/\\\-' '_')
    HOOK="${HOOK_PREFIX}_${HOOK_NAME}"

    echo $HOOK
    return 0
}

hook_var_exists() {
    local VAR=$1

    [[ -n ${!VAR+x} ]]
}

hook_register_action_array() {
    local HOOK=$1

    # Get the variable for the hook
    local HOOK_VAR=$(hook_get_var_name $HOOK)

    # Check if the variable exists
    hook_var_exists $HOOK_VAR && return 0

    # Execute the create variable command
    hook_evaluate_variable create "$HOOK_VAR"
}

hook_add_action() {
    local HOOK=$1
    local ACTION=$2

    # Get the variable for this hook
    local HOOK_VAR=$(hook_get_var_name $HOOK)

    # If the hook variable doesn't exist, bail
    hook_var_exists $HOOK_VAR || return 0

    # Execute the add action command
    hook_evaluate_variable add "$HOOK_VAR" "$ACTION"
}

hook_evaluate_variable() {
    local MODE=$1
    local VARIABLE=$2
    local ACTIONS=(${@:3})

    local CMDLINE

    # Determine the mode
    case $MODE in

        # Create the array
        create)
            CMDLINE="${VARIABLE}=()"
            ;;

        # Add an item to the array
        add)
            CMDLINE="${VARIABLE}+=(%s)"
            ;;

        # Default is no mode
        *)
            return 1
            ;;

    esac

    # Add the actions to the variable
    CMDLINE=$(printf "$CMDLINE" "${ACTIONS[@]}")

    # Evaluate the command.
    # Eval is used here instead of declare because the variable needs to be in the global scope and not local scope
    eval "$CMDLINE"
}
