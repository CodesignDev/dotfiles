#!/usr/bin/env bash

BREW_INITIAL_UPDATE_DONE=0

brew() {
    local BREW_CMD=\brew
    local COMMAND=$1
    local ARGS=(${@:2})

    case $COMMAND in
        install | upgrade)
            [[ $BREW_INITIAL_UPDATE_DONE == 0 ]] && brew update
            ;;
        update)
            [[ $BREW_INITIAL_UPDATE_DONE == 0 ]] && BREW_INITIAL_UPDATE_DONE=1
        *)
            ;;
    esac

    $BREW_CMD $COMMAND ${ARGS[*]}
}

brew_install_package() {
    local PACKAGES=$@

    package_manager_exists brew || return

    for PACKAGE IN ${PACKAGES[@]}; do
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

    for PACKAGE IN ${PACKAGES[@]}; do
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
