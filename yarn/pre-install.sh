#!/usr/bin/env bash

# Currently linux only
is_linux || return 0

# Remove cmdtest if it is installed
if $(is_package_installed_apt cmdtest); then
    sudo_askpass apt remove cmdtest
fi
