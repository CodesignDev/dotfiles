#!/usr/bin/env bash
set -e

# Homebrew can only be installed on *nix systems
[[ $UNIX ]] || return 0

# If home brew is already installed, skip this script
command_exists brew && return 0

# If homebrew is not to be installed, then skip the install
[[ $INSTALL_HOMEBREW ]] || {
    line "Homebrew installation skipped..."
    return 0
}

# Install script location
HOMEBREW_INSTALL_PATH=
[[ $MACOS ]] && HOMEBREW_INSTALL_PATH="https://raw.githubusercontent.com/Hombrew/install/master/install"
[[ $LINUX ]] && HOMEBREW_INSTALL_PATH="https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh"

# Download and run the install script
line "Downloading and installing Homebrew..."
sh -c "$( curl -fsSL $HOMEBREW_INSTALL_PATH"
