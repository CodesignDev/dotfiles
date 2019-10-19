#!/usr/bin/env bash
set -e

# This script is in a folder called apt so that it gets called first during the
# prereg section of the bootstrap process. This is because a lot of the other
# scripts rely on the programs being installed here to function correctly

# If these dotfiles were installed using like my dotfiles-installer then the
# relevant software will most likely already have been installed.

# If this script fails to install the relevant software, perhaps because it is
# running on a linux system that doesn't have apt available (Hi Fedora, CentOS,
# & Red Hat) then some parts of the dotfiles will not install. Homebrew being an
# example.

# This is only for OS X
[[ $LINUX == 1 ]] || return 0

# Is APT available?
command_exists apt || {
    error "This script only supports auto installation Debian and Ubuntu."
    INSTALL_HOMEBREW=0
    return 0
}

# Allow homebrew to be installed
INSTALL_HOMEBREW=1

# Update apt
apt_update

# Install some core dependencies
line "Installing some prerequisite software for Linux..."
apt_install build-essential curl file git
