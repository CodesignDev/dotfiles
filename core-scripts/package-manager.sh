#!/usr/bin/env bash

INSTALLED_PACKAGE_MANAGERS=()
PACKAGE_MANAGER_INITIALIZED=0
init_package_manager_actions() {
    [[ $PACKAGE_MANAGER_INITIALIZED == 1 ]] && return

    if [[ $UNIX == 1 ]]; then
        local PACKAGE_MANAGERS=($(get_installed_package_managers))

        for PACKAGE_MANAGER in ${PACKAGE_MANAGERS[@]}; do
            local PACKAGE_MANAGER_CMD=$(echo $PACKAGE_MANAGER | cut -f 1 -d :)
            local PACKAGE_MANAGER_FILE=$(echo $PACKAGE_MANAGER | cut -f 2 -d :)
            if [[ -f $CORE_SCRIPTS_DIR/packages/$PACKAGE_MANAGER_FILE ]]; then
                source $CORE_SCRIPTS_DIR/packages/$PACKAGE_MANAGER_FILE
                INSTALLED_PACKAGE_MANAGERS+=($PACKAGE_MANAGER_CMD)
            fi
        done
    fi

    PACKAGE_MANAGER_INITIALIZED=1
}

get_installed_package_managers() {
    for PACKAGE_MANAGER in $CORE_SCRIPTS_DIR/packages/*.sh; do
        local PACKAGE_MANAGER_FILE=$(basename $PACKAGE_MANAGER)
        local PACKAGE_MANAGER_CMD=$(get_package_manager_cmd $PACKAGE_MANAGER)
        package_manager_exists $PACKAGE_MANAGER_CMD && echo $PACKAGE_MANAGER_CMD:$PACKAGE_MANAGER_FILE
    done
}

package_manager_cmd_exec() {
    local COMMAND=$1
    local ARGS=(${@:2})

    for PACKAGE_MANAGER in ${INSTALLED_PACKAGE_MANAGERS[@]}; do
        is_package_manager_restricted $PACKAGE_MANAGER && continue
        PACKAGE_MANAGER_FUNC="${PACKAGE_MANAGER}_${COMMAND}"

        $PACKAGE_MANAGER_FUNC ${ARGS[@]}
    done
}

package_manager_cmd_exec_for_each() {
    local COMMAND=$1
    local PACKAGES=(${@:2})

    for PACKAGE in ${PACKAGES[@]}; do
        $COMMAND $PACKAGE
    done
}

get_package_manager_cmd() {
    local COMMAND=$1

    COMMAND=$(basename $COMMAND)
    COMMAND=${COMMAND%.*}
    COMMAND=${COMMAND#*-}

    echo $COMMAND
}

package_manager_exists() {
    local PACKAGE_MANAGER=$1

    command_exists $PACKAGE_MANAGER
}

is_valid_package_manager() {
    local PACKAGE_MANAGER=$1

    for VALID_PACKAGE_MANAGER in ${INSTALLED_PACKAGE_MANAGERS[@]}; do
        [[ "$PACKAGE_MANAGER" == "$VALID_PACKAGE_MANAGER" ]] && return 0
    done
    return 1
}

is_package_manager_restricted() {
    if is_interactive input; then
        return 1
    fi

    local FILTERED_PACKAGE_MANAGERS=$(get_restricted_package_managers)
    local REQUESTED_PACKAGE_MANAGER=$1

    for FILTERED_PACKAGE_MANAGER in ${FILTERED_PACKAGE_MANAGERS[@]}; do
        [[ "$REQUESTED_PACKAGE_MANAGER" == "$FILTERED_PACKAGE_MANAGER" ]] && return 0
    done
    return 1
}

get_restricted_package_managers() {
    is_interactive input && {
        echo ""
        return 0
    }

    local PASSED_PACKAGE_MANAGERS=$(get_stdin)
    local RESTRICTED_PACKAGE_MANAGERS=()
    for PACKAGE_MANAGER in ${PASSED_PACKAGE_MANAGERS[@]}; do
        local PACKAGE_MANAGER_KEY=$(echo $PACKAGE_MANAGER | cut -f 1 -d :)
        local PACKAGE_MANAGER_CMD=$(echo $PACKAGE_MANAGER | cut -f 2 -d :)

        if [[ "$PACKAGE_MANAGER_KEY" == "PACKAGE_mgr" ]]; then
            is_valid_package_manager $PACKAGE_MANAGER_CMD && RESTRICTED_PACKAGE_MANAGERS+=($PACKAGE_MANAGER_CMD)
        fi
    done

    for PACKAGE_MANAGER in ${RESTRICTED_PACKAGE_MANAGERS[@]}; do
        echo $PACKAGE_MANAGER
    done
}

restrict_package_managers() {
    local PACKAGE_MANAGERS=($@)

    for PACKAGE_MANAGER in ${PACKAGE_MANAGERS[@]}; do
        is_valid_package_manager $PACKAGE_MANAGER || continue
        echo "PACKAGE_mgr:$PACKAGE_MANAGER"
    done
}
