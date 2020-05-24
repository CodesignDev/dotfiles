#!/usr/bin/env bash

INSTALLED_PACKAGE_MANAGERS=()
LOADED_PACKAGE_MANAGERS=()
PACKAGE_MANAGER_INITIALIZED=0

RESTRICTED_PACKAGE_MANAGER_GLOBAL_KEY="PACKAGE_mgr"
init_package_manager_actions() {
    [[ $PACKAGE_MANAGER_INITIALIZED == 1 ]] && return

    # Package managers only seem to be on unix based systems (sorry windows)
    if is_unix; then
        local PACKAGE_MANAGERS=($(get_installed_package_managers))

        # Reset the installed list
        INSTALLED_PACKAGE_MANAGERS=()

        # Loop through each detected package manager
        for PACKAGE_MANAGER in ${PACKAGE_MANAGERS[@]}; do

            # Get the command and the file
            local PACKAGE_MANAGER_CMD=$(echo $PACKAGE_MANAGER | cut -f 1 -d :)
            local PACKAGE_MANAGER_FILE=$(echo $PACKAGE_MANAGER | cut -f 2 -d :)

            # Does the file exist
            if [[ -f $CORE_SCRIPTS_DIR/packages/$PACKAGE_MANAGER_FILE ]]; then

                # Load the file if it hasn't already been loaded
                if ! is_package_manager_loaded $PACKAGE_MANAGER_FILE; then

                    # Load the file
                    source $CORE_SCRIPTS_DIR/packages/$PACKAGE_MANAGER_FILE
                    LOADED_PACKAGE_MANAGERS+=($PACKAGE_MANAGER_FILE)
                fi

                # Mark the file as installed
                INSTALLED_PACKAGE_MANAGERS+=($PACKAGE_MANAGER_CMD)
            fi
        done
    fi

    # Mark the system as initialized
    PACKAGE_MANAGER_INITIALIZED=1
}

update_managed_package_managers() {

    # Reinitialize the detected package manager list
    PACKAGE_MANAGER_INITIALIZED=0
    init_package_manager_actions
}

get_installed_package_managers() {

    # Loop through each file in the packages folder
    for PACKAGE_MANAGER in $CORE_SCRIPTS_DIR/packages/*.sh; do

        # Get the file name and command
        local PACKAGE_MANAGER_FILE=$(basename $PACKAGE_MANAGER)
        local PACKAGE_MANAGER_CMD=$(get_package_manager_cmd $PACKAGE_MANAGER)

        # Check if the command exists on the system
        package_manager_exists $PACKAGE_MANAGER_CMD && echo $PACKAGE_MANAGER_CMD:$PACKAGE_MANAGER_FILE
    done
}

package_manager_cmd_exec() {
    local COMMAND=$1
    local ARGS=(${@:2})

    local RETURN_CODE=0

    # Loop through each installed package manager
    for PACKAGE_MANAGER in ${INSTALLED_PACKAGE_MANAGERS[@]}; do

        # Check if this run is restricted to certain package managers
        is_package_manager_restricted $PACKAGE_MANAGER && continue

        # Call the neccessary function
        PACKAGE_MANAGER_FUNC="${PACKAGE_MANAGER}_${COMMAND}"
        $PACKAGE_MANAGER_FUNC ${ARGS[@]}

        # Capture the return code
        RETURN_CODE=$?

        # If the command executed successfully, then exit, otherwise move to the next
        [[ $RETURN_CODE -eq 0 ]] && return 0
    done
}

package_manager_cmd_exec_for_each() {
    local COMMAND=$1
    local PACKAGES=(${@:2})

    # Loop through each package calling the necessary command
    for PACKAGE in ${PACKAGES[@]}; do
        $COMMAND $PACKAGE
    done
}

get_package_manager_cmd() {
    local COMMAND=$1

    # Get the command from the file name (remove the order prefix and extension)
    COMMAND=$(basename $COMMAND)
    COMMAND=${COMMAND%.*}
    COMMAND=${COMMAND#*-}

    echo $COMMAND
}

package_manager_exists() {
    local PACKAGE_MANAGER=$1

    command_exists $PACKAGE_MANAGER
}

is_package_manager_loaded() {
    local PACKAGE_MANAGER_FILE=$1

    # Check if the passed parameter exists in the array
    array_is_valid_entry $PACKAGE_MANAGER_FILE ${LOADED_PACKAGE_MANAGERS[@]}
    # for PACKAGE_MANAGER in ${LOADED_PACKAGE_MANAGERS[@]}; do
    #     [[ "$PACKAGE_MANAGER" == "$PACKAGE_MANAGER_FILE" ]] && return 0
    # done
    # return 1
}

is_package_manager_valid() {
    local PACKAGE_MANAGER=$1

    # Check if the passed parameter
    array_is_valid_entry $PACKAGE_MANAGER_FILE ${INSTALLED_PACKAGE_MANAGERS[@]}
    # for VALID_PACKAGE_MANAGER in ${INSTALLED_PACKAGE_MANAGERS[@]}; do
    #     [[ "$PACKAGE_MANAGER" == "$VALID_PACKAGE_MANAGER" ]] && return 0
    # done
    # return 1
}

is_package_manager_restricted() {
    if is_interactive input; then
        return 1
    fi

    # Get a list of restricted package managers
    local FILTERED_PACKAGE_MANAGERS=$(get_restricted_package_managers)
    local REQUESTED_PACKAGE_MANAGER=$1

    # Check if this package manager has been restricted
    array_is_valid_entry $REQUESTED_PACKAGE_MANAGER ${FILTERED_PACKAGE_MANAGERS[@]}
    # for FILTERED_PACKAGE_MANAGER in ${FILTERED_PACKAGE_MANAGERS[@]}; do
    #     [[ "$REQUESTED_PACKAGE_MANAGER" == "$FILTERED_PACKAGE_MANAGER" ]] && return 0
    # done
    # return 1
}

get_restricted_package_managers() {
    is_interactive input && {
        echo ""
        return 0
    }

    # Get the restricted package manager codes that have been passed via stdin
    local PASSED_PACKAGE_MANAGERS=$(get_stdin)

    # Loop through each code passed
    local RESTRICTED_PACKAGE_MANAGERS=()
    for PACKAGE_MANAGER in ${PASSED_PACKAGE_MANAGERS[@]}; do

        # Get the key and command from the code
        local PACKAGE_MANAGER_KEY=$(echo $PACKAGE_MANAGER | cut -f 1 -d :)
        local PACKAGE_MANAGER_CMD=$(echo $PACKAGE_MANAGER | cut -f 2 -d :)

        # Check if the key matches our global pattern and add the code to the list
        if [[ "$PACKAGE_MANAGER_KEY" == "$RESTRICTED_PACKAGE_MANAGER_GLOBAL_KEY" ]]; then
            is_package_manager_valid $PACKAGE_MANAGER_CMD && RESTRICTED_PACKAGE_MANAGERS+=($PACKAGE_MANAGER_CMD)
        fi
    done

    # Return the list of restricted package managers
    echo ${RESTRICTED_PACKAGE_MANAGERS[@]}
    # for PACKAGE_MANAGER in ${RESTRICTED_PACKAGE_MANAGERS[@]}; do
    #     echo $PACKAGE_MANAGER
    # done
}

restrict_package_managers() {
    local PACKAGE_MANAGERS=($@)

    # For each passed package manager, add it to our list to pass to the next command
    for PACKAGE_MANAGER in ${PACKAGE_MANAGERS[@]}; do
        is_package_manager_valid $PACKAGE_MANAGER || continue
        echo "$RESTRICTED_PACKAGE_MANAGER_GLOBAL_KEY:$PACKAGE_MANAGER"
    done
}
