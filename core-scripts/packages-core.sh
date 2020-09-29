#!/usr/bin/env bash

packages() {
    local COMMAND=$1
    local ARGS=${@:2}

    local PACKAGE_MANAGER_COMMAND=package_manager_cmd_exec
    local PACKAGE_COMMAND

    case $COMMAND in

        # Install package(s)
        install)
            PACKAGE_COMMAND=install_package
            ;;

        # Install package group
        install_group)
            PACKAGE_COMMAND=install_package_group
            ;;

        # Update package managers
        update)
            PACKAGE_COMMAND=update_packages
            ;;

        # Upgrade package(s)
        upgrade)
            PACKAGE_COMMAND=upgrade_packages
            ;;

        remove)
            PACKAGE_COMMAND=remove_packages
            ;;

        purge)
            PACKAGE_COMMAND=purge_packages
            ;;

        # Add package repository
        add_repo | add_repository | add_package_repository)
            PACKAGE_COMMAND=add_package_repository
            ;;

        # Is package installed?
        is_installed)
            PACKAGE_COMMAND=is_package_installed
            ;;

        # List files for a package
        list_files)
            PACKAGE_COMMAND=list_package_files
            ;;

        # ----------------------------------------

        # Restrict command to particular package manager(s)
        restrict)
            PACKAGE_MANAGER_COMMAND=restrict_package_managers
            ;;

        # Unknown command
        *)
            warning "Unknown command to packages"
            return 1

    esac

    # Run the command
    $PACKAGE_MANAGER_COMMAND $PACKAGE_COMMAND ${ARGS[@]}
}

install_package() {
    package_manager_cmd_exec install_package $@
}

install_package_group() {
    package_manager_cmd_exec install_package_group $@
}

update_package_managers() {
    package_manager_cmd_exec update_packages $@
}

add_package_repository() {
    package_manager_cmd_exec add_repository $@
}

is_package_installed() {
    package_manager_cmd_exec is_package_installed $@
}

list_package_files() {
    package_manager_cmd_exec list_package_files $@
}
