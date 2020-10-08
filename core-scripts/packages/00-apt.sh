#!/usr/bin/env bash

APT_INITIAL_UPDATE_DONE=0
APT_PACKAGE_QUEUE=()

apt() {
    local APT_CMD=$(get_command_path apt)
    local COMMAND=$1
    local ARGS=(${@:2})

    local APT_NO_INSTALL_RECOMMENDS=${APT_NO_INSTALL_RECOMMENDS:-0}
    local APT_COMMAND_ARGS=${APT_COMMAND_ARGS:-}

    local SUDO_COMMAND="sudo_askpass"
    local COMMAND_PREFIX=
    local COMMAND_ARGS=()

    COMMAND_ARGS+=($QUIET_FLAG_APT)
    COMMAND_ARGS+=($APT_COMMAND_ARGS)

    case $COMMAND in
        install | upgrade)
            [[ "$APT_NO_INSTALL_RECOMMENDS" == "1" ]] && COMMAND_ARGS+=(--no-install-recommends)
            COMMAND_PREFIX="DEBIAN_FRONTEND=noninteractive "
            COMMAND_ARGS+=(-y)
            ;;
        update)
            COMMAND_ARGS+=(-y)
            ;;
        remove | purge)
            [[ "$COMMAND" == "purge" ]] && COMMAND_ARGS+=(--purge)
            COMMAND="remove"
            COMMAND_ARGS+=(-y)
            ;;
        search)
            APT_CMD=$(get_command_path apt-cache)
            ;;
        *)
            ;;
    esac

    $SUDO_COMMAND $COMMAND_PREFIX$APT_CMD $COMMAND ${COMMAND_ARGS[*]} ${ARGS[*]}
}

apt_install_package() {
    local PACKAGES=$@

    package_manager_exists apt || return

    APT_QUEUE_ACTION=install package_manager_cmd_exec_for_each apt_queue_package ${PACKAGES[@]}
    apt_action_queued_packages install
}

apt_install_package_group() {
    true
}

apt_update_packages() {
    apt update
}

apt_upgrade_packages() {
    local PACKAGES=$@

    package_manager_exists apt || return

    if [[ ${#PACKAGES[@]} -eq 0 ]]; then
        apt upgrade
    else
        APT_QUEUE_ACTION=upgrade package_manager_cmd_exec_for_each apt_queue_package ${PACKAGES[@]}
        apt_action_queued_packages upgrade
    fi
}

apt_remove_packages() {
    local PACKAGES=$@

    package_manager_exists apt || return

    APT_QUEUE_ACTION=remove package_manager_cmd_exec_for_each apt_queue_package ${PACKAGES[@]}
    apt_action_queued_packages remove
}

apt_purge_packages() {
    local PACKAGES=$@

    package_manager_exists apt || return

    APT_QUEUE_ACTION=remove package_manager_cmd_exec_for_each apt_queue_package ${PACKAGES[@]}
    apt_action_queued_packages purge
}

apt_add_package_repository() {
    local REPOSITORY=$1
    local REPOSITORY_URL=$2
    local REPOSITORY_RELEASE_NAME=$3
    local REPOSITORY_COMPONENT_NAMES=$4
    local GPGKEY_URL=$5

    apt_install_package_repository_prerequisites

    local IS_PPA_REPO=0
    [[ "$REPOSITORY" =~ ^ppa\:.* ]] && IS_PPA_REPO=1

    if [[ $IS_PPA_REPO == 1 ]]; then

        local PPA_REPOSITORY_NAME=${REPOSITORY:4}

        line "Adding PPA repository '$PPA_REPOSITORY_NAME'..."
        sudo_askpass add-apt-repository $REPOSITORY

    else

        local APT_SOURCE_FILE="/etc/apt/sources.list.d/$REPOSITORY.list"

        [[ -f "$APT_SOURCE_FILE" ]] && return

        line "Adding apt repository '$REPOSITORY_URL'..."
        curl -sS $GPGKEY_URL | sudo_askpass apt-key add -
        echo "deb $REPOSITORY_URL $REPOSITORY_RELEASE_NAME $REPOSITORY_COMPONENT_NAMES" | sudo_askpass tee -a $APT_SOURCE_FILE
    fi

    apt_update_packages
}

apt_is_package_available() {
    local PACKAGE=$1

    apt search $PACKAGE | awk '{print $1}' | grep $QUIET_FLAG_GREP "$PACKAGE$" 2>/dev/null
}

apt_is_package_installed() {
    local PACKAGE=$1

    dpkg --get-selections | awk '{print $1}' | grep $QUIET_FLAG_GREP "$PACKAGE$" 2>/dev/null
}

apt_list_package_files() {
    local PACKAGE=$1

    dpkg -L $PACKAGE 2>/dev/null
}

apt_queue_package() {
    local PACKAGE=$1

    apt_queue_check_package $PACKAGE && return
    APT_PACKAGE_QUEUE+=($PACKAGE)
}

apt_queue_check_package() {
    local PACKAGE=$1

    local APT_QUEUE_ACTION=${APT_QUEUE_ACTION:-install}

    case $APT_QUEUE_ACTION in

        install)
            apt_is_package_available $PACKAGE || return 0
            apt_is_package_installed $PACKAGE && return 0
            ;;

        upgrade | remove)
            apt_is_package_installed $PACKAGE || return 0
            ;;

    esac

    return 1
}

apt_action_queued_packages() {
    local APT_COMMAND=${1:-install}
    local RETURN_CODE=0

    if [[ ${#APT_PACKAGE_QUEUE[@]} -gt 0 ]]; then
        apt $APT_COMMAND ${APT_PACKAGE_QUEUE[*]}
        RETURN_CODE=$?
    fi

    apt_clear_queue

    return $RETURN_CODE
}

apt_clear_queue() {
    APT_PACKAGE_QUEUE=()
}

apt_perform_initial_update() {
    if [[ $APT_INITIAL_UPDATE_DONE == 0 ]]; then
        apt update
        APT_INITIAL_UPDATE_DONE=1
    fi
}

apt_install_package_repository_prerequisites() {
    local PACKAGE_LIST=(curl software-properties-common)
    dpkg --compare-versions "1.5" "lt" "$(apt --version | awk '{print $2}')" || PACKAGE_LIST+=(apt-transport-https)

    package_manager_cmd_exec_for_each apt_queue_package ${PACKAGE_LIST[@]}

    if [[ ${#APT_PACKAGE_QUEUE[*]} -eq 0 ]]; then
        apt_clear_queue
        return 0
    fi

    line "Installing prerequisites for adding apt repositories..."
    apt_action_queued_packages install

    return 0
}
