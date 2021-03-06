#!/usr/bin/env bash

BREW_INITIAL_UPDATE_DONE=0

brew() {
    local BREW_CMD=$(get_command_path brew)
    local COMMAND=$1
    local ARGS=(${@:2})

    local BREW_INSTALL_HEAD=${BREW_INSTALL_HEAD:-0}
    local BREW_COMMAND_ARGS=${BREW_COMMAND_ARGS:-}

    local COMMAND_ARGS=()

    COMMAND_ARGS+=($QUIET_FLAG_BREW)
    COMMAND_ARGS+=($BREW_COMMAND_ARGS)

    [[ "$BREW_INSTALL_HEAD" == "1" ]] && COMMAND_ARGS+=(--HEAD)

    $BREW_CMD $COMMAND ${COMMAND_ARGS[*]} ${ARGS[*]}
}

brew_install_package() {
    local PACKAGES=$@

    package_manager_exists brew || return

    for PACKAGE in ${PACKAGES[@]}; do
        brew_is_package_available $PACKAGE || continue
        brew_is_package_installed $PACKAGE && continue

        brew install $PACKAGE
    done
}

brew_install_package_group() {
    true # No-op
}

brew_update_packages() {
    brew update
}

brew_upgrade_packages() {
    local PACKAGES=$@

    package_manager_exists brew || return

    [[ ${#PACKAGES[@]} -eq 0 ]] && brew upgrade

    for PACKAGE in ${PACKAGES[@]}; do
        brew_is_package_installed $PACKAGE || continue

        brew upgrade $PACKAGE
    done
}

brew_remove_packages() {
    local PACKAGES=$1

    package_manager_exists brew || return

    for PACKAGE in ${PACKAGES[@]}; do
        brew_is_package_installed $PACKAGE || continue

        brew uninstall --force $PACKAGE
    done
}

brew_purge_packages() {
    brew_remove_packages $@
}

brew_add_package_repository() {
    local REPOSITORY=$1

    brew tap | grep $QUIET_FLAG_GREP $REPOSITORY || {
        line "Adding brew tap '$REPO'..."
        brew tap "$REPO"
    }
}

brew_is_package_available() {
    local PACKAGE=$1

    brew search --formula $PACKAGE | tail -n +2 | awk '{print $1}' | grep $QUIET_FLAG_GREP "^$PACKAGE" 2>/dev/null
}

brew_is_package_installed() {
    local PACKAGE=$1
    PACKAGE=$(basename $PACKAGE)

    brew list | grep $QUIET_FLAG_GREP "$PACKAGE$" 2>/dev/null
}

brew_list_package_files() {
    local PACKAGE=$1

    brew_is_package_installed $PACKAGE || return
    brew list -v $PACKAGE 2>/dev/null
}

brew_perform_initial_update() {
    if [[ $BREW_INITIAL_UPDATE_DONE == 0 ]]; then
        brew update
        BREW_INITIAL_UPDATE_DONE=1
    fi
}
