#!/usr/bin/env bash

SUPPORTED_PACKAGE_MANAGERS=()
SUPPORTED_PACKAGE_MANAGER_DATA=()
INSTALLED_PACKAGE_MANAGERS=()
LOADED_PACKAGE_MANAGERS=()
PACKAGE_MANAGER_INITIALIZED=0
PACKAGE_MANAGER_LIST_GENERATED=0

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
                if ! check_package_manager is_loaded $PACKAGE_MANAGER_FILE; then

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

get_supported_package_managers() {

    # Check if we have already generated the list of package managers
    if [[ "$PACKAGE_MANAGER_LIST_GENERATED" == "0" ]]; then

        # Loop through each file in the packages folder
        for PACKAGE_MANAGER in $CORE_SCRIPTS_DIR/packages/*.sh; do

            # Get the file name and command
            local PACKAGE_MANAGER_FILE=$(basename $PACKAGE_MANAGER)
            local PACKAGE_MANAGER_CMD=$(get_package_manager_cmd $PACKAGE_MANAGER)

            # Add the file to the list of supported package managers
            SUPPORTED_PACKAGE_MANAGERS+=($PACKAGE_MANAGER_CMD)
            SUPPORTED_PACKAGE_MANAGER_DATA+=($PACKAGE_MANAGER_CMD:$PACKAGE_MANAGER_FILE)
        done

        # Set flag saying that the list has been generated
        PACKAGE_MANAGER_LIST_GENERATED=1

    fi

    # Print the list of supported package managers
    echo ${SUPPORTED_PACKAGE_MANAGER_DATA[@]}
}

get_installed_package_managers() {

    # Get the list of supported package managers
    local PACKAGE_MANAGERS=$(get_supported_package_managers)

    # Loop through each file in the packages folder
    for PACKAGE_MANAGER in ${PACKAGE_MANAGERS[@]}; do

        # Get the command and the file
        local PACKAGE_MANAGER_CMD=$(echo $PACKAGE_MANAGER | cut -f 1 -d :)
        local PACKAGE_MANAGER_FILE=$(echo $PACKAGE_MANAGER | cut -f 2 -d :)

        # Check if the command exists on the system
        package_manager_exists $PACKAGE_MANAGER_CMD && echo $PACKAGE_MANAGER
    done
}

package_manager_cmd_exec() {
    local COMMAND=$1
    local ARGS=(${@:2})

    local RETURN_CODE=0

    # Get the list of restricted package managers
    local RESTRICTED_PACKAGE_MANAGERS=($(get_restricted_package_managers))

    # Loop through each installed package manager
    for PACKAGE_MANAGER in ${INSTALLED_PACKAGE_MANAGERS[@]}; do

        # Check if this package manager should be skipped
        is_package_manager_restricted $PACKAGE_MANAGER ${RESTRICTED_PACKAGE_MANAGERS[@]} || continue

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

check_package_manager() {
    local MODE=$1
    local PACKAGE_MANAGER=$2

    # Get the list of packages
    local PACKAGE_MANAGER_LIST=($(get_package_manager_list $MODE))

    # If there are no entries in the list, bail
    [[ -z $PACKAGE_MANAGER_LIST ]] && return 1

    # Check if the entry is in the array
    array_is_valid_entry $PACKAGE_MANAGER ${PACKAGE_MANAGER_LIST[@]}
}

get_package_manager_list() {
    local LIST=$1
    local PACKAGE_MANAGER_LIST

    # Get the correct variable
    case $LIST in

        # Is the package manager supported by this system
        is_supported)
            PACKAGE_MANAGER_LIST="SUPPORTED_PACKAGE_MANAGERS"
            ;;

        # Is the script file loaded in
        is_loaded)
            PACKAGE_MANAGER_LIST="LOADED_PACKAGE_MANAGERS"
            ;;

        # Is a valid package manager
        is_valid)
            PACKAGE_MANAGER_LIST="INSTALLED_PACKAGE_MANAGERS"
            ;;

    esac

    # If nothing was selected, just exit without check
    if [[ -z $PACKAGE_MANAGER_LIST ]]; then
        echo ""
        return 1
    fi

    # Format the variable name and then return the list
    PACKAGE_MANAGER_LIST="${PACKAGE_MANAGER_LIST}[@]"
    echo ${!PACKAGE_MANAGER_LIST}
}

is_package_manager_restricted() {
    if is_interactive input; then
        return 0
    fi

    # Get a list of restricted package managers
    local REQUESTED_PACKAGE_MANAGER=$1
    local RESTRICTED_PACKAGE_MANAGERS=(${@:2})

    # If there are no entries, then there is no restriction
    [[ ${#RESTRICTED_PACKAGE_MANAGERS[@]} -gt 0 ]] || return 0

    # Check if this package manager is in the restricted list
    array_is_valid_entry $REQUESTED_PACKAGE_MANAGER ${RESTRICTED_PACKAGE_MANAGERS[@]}
}

restrict_package_managers() {
    local PACKAGE_MANAGERS=($@)
    local CURRENT_PACKAGE

    # For each passed package manager, add it to our list to pass to the next command
    for PACKAGE_MANAGER in ${PACKAGE_MANAGERS[@]}; do
        CURRENT_PACKAGE=$(echo $PACKAGE_MANAGER | sed -r 's/!//g')
        check_package_manager is_supported $PACKAGE_MANAGER || continue
        echo "$RESTRICTED_PACKAGE_MANAGER_GLOBAL_KEY:$PACKAGE_MANAGER"
    done
}

get_restricted_package_managers() {
    if is_interactive input; then
        echo ""
        return 0
    fi

    # Get the restricted package manager codes that have been passed via stdin
    local PASSED_PACKAGE_MANAGERS=$(get_stdin)
    local FILTERED_PACKAGE_MANAGERS

    # Process the list of package managers
    PASSED_PACKAGE_MANAGERS=($(get_restricted_package_manager_list ${PASSED_PACKAGE_MANAGERS[@]}))

    # Get the list of package managers that match our filter
    FILTERED_PACKAGE_MANAGERS=($(filter_package_manager_list ${PASSED_PACKAGE_MANAGERS[@]}))

    # Return the list of restricted package managers
    echo ${FILTERED_PACKAGE_MANAGERS[@]}
}

get_restricted_package_manager_list() {
    local PACKAGE_MANAGER_LIST=($@)

    # Loop through each code passed
    local RESTRICTED_PACKAGE_MANAGERS=()
    for PACKAGE_MANAGER in ${PACKAGE_MANAGER_LIST[@]}; do

        # Get the key and command from the code
        local PACKAGE_MANAGER_KEY=$(echo $PACKAGE_MANAGER | cut -f 1 -d :)
        local PACKAGE_MANAGER_CMD=$(echo $PACKAGE_MANAGER | cut -f 2 -d :)

        # Check if the key matches our global pattern and add the code to the list
        if [[ "$PACKAGE_MANAGER_KEY" == "$RESTRICTED_PACKAGE_MANAGER_GLOBAL_KEY" ]]; then
            RESTRICTED_PACKAGE_MANAGERS+=($PACKAGE_MANAGER_CMD)
        fi
    done

    # Return the list of restricted package managers
    echo ${RESTRICTED_PACKAGE_MANAGERS[@]}
}

filter_package_manager_list() {
    local FILTER_LIST=($1)

    local NEGATE_MODE=0

    # Get the list of valid package managers
    local PACKAGE_MANAGER_LIST=($(get_package_manager_list is_valid))
    local FILTERED_PACKAGE_MANAGER_LIST=()

    local FILTER_ENTRIES=()

    # Check for any negative flags
    for ENTRY in ${FILTER_LIST[@]}; do
        [[ "$ENTRY" == '!'* ]] && NEGATE_MODE=1
    done

    # Get the correct filter list depending on the mode
    for ENTRY in ${FILTER_LIST[@]}; do # apt
        if [[ "$NEGATE_MODE" == "1" ]]; then # false
            [[ "$ENTRY" == '!'* ]] || continue
        else
            [[ "$ENTRY" == '!'* ]] && continue # skips
        fi
        ENTRY=$(echo $ENTRY | sed -r 's/!//g')
        FILTER_ENTRIES+=($ENTRY) # Adds apt
    done

    # Loop through each entry in the package manager list and check it against the filter list
    for PACKAGE_MANAGER in ${PACKAGE_MANAGER_LIST[@]}; do
        if [[ "$NEGATE_MODE" == "1" ]]; then
            array_is_valid_entry $PACKAGE_MANAGER ${FILTER_ENTRIES[@]} && continue
        else
            array_is_valid_entry $PACKAGE_MANAGER ${FILTER_ENTRIES[@]} || continue
        fi
        FILTERED_PACKAGE_MANAGER_LIST+=($PACKAGE_MANAGER)
    done

    # Return the list of filtered package managers
    echo ${FILTERED_PACKAGE_MANAGER_LIST[@]}
}

clean_package_manager_name() {
    local PACKAGE_MANAGER=$1

    # Clean the name
    PACKAGE_MANAGER=$(echo $PACKAGE_MANAGER | sed -r 's/!//g')

    # REturn the name
    echo $PACKAGE_MANAGER
}
