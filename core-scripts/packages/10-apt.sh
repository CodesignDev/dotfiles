#!/usr/bin/ebnv bash

APT_INITIAL_UPDATE_DONE=0
APT_INSTALL_QUEUE=()

apt() {
    local COMMAND=$1
    local ARGS=(${@:2})

    local SUDO_COMMAND="sudo_askpass"
    local COMMAND_PREFIX=
    local COMMAND_ARGS=$QUIET_FLAG_APT

    case $COMMAND in
        install)
            [[ $APT_INITIAL_UPDATE_DONE == 0 ]] && apt update
            COMMAND_PREFIX=" DEBIAN_FRONTEND=noninteractive"
            COMMAND_ARGS+="-y"
            ;;
        update)
            [[ $APT_INITIAL_UPDATE_DONE == 0 ]] && APT_INITIAL_UPDATE_DONE=1
            COMMAND_ARGS+="-y"
            ;;
        *)
            ;;
    esac

    $SUDO_COMMAND$COMMAND_PREFIX \apt $COMMAND ${COMMAND_ARGS[*]} ${ARGS[*]}
}

apt_install_package() {
    local PACKAGES=$@

    package_manager_exists apt || return

    package_manager_cmd_exec_for_each apt_install_queue_package ${PACKAGES[@]}
    apt_install_queued_packages
}

apt_install_package_group() {
    true
}

apt_update_packages() {
    apt update
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

apt_is_package_installed() {
    local PACKAGE=$1

    dpkg --get-selections | awk '{print $1}' | grep $QUIET_FLAG_GREP "$PACKAGE$" 2>/dev/null
}

apt_list_package_files() {
    local PACKAGE=$1

    dpkg -L $PACKAGE 2>/dev/null
}

apt_install_queue_package() {
    local PACKAGE=$1

    apt_is_package_installed $PACKAGE && return
    APT_INSTALL_QUEUE+=($PACKAGE)
}

apt_install_queued_packages() {
    [[ ${#APT_INSTALL_QUEUE[@]} -gt 0 ]] && apt install ${APT_INSTALL_QUEUE[*]}
    apt_install_clear_queue
}

apt_install_clear_queue() {
    APT_INSTALL_QUEUE=()
}

apt_install_package_repository_prerequisites() {
    local PACKAGE_LIST=(curl software-properties-common)
    dpkg --compare-versions "1.5" "lt" "$(apt --version | awk '{print $2}')" || PACKAGE_LIST+=(apt-transport-https)

    package_manager_cmd_exec_for_each apt_install_queue_package ${PACKAGE_LIST[@]}

    if [[ ${#APT_INSTALL_QUEUE[*]} -eq 0 ]]; then
        apt_install_clear_queue
        return 0
    fi

    line "Installing prerequisites for adding apt repositories..."
    apt_install_queued_packages

    return 0
}
