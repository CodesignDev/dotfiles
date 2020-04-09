#!/usr/bin/env bash

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
