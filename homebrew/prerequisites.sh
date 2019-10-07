#!/usr/bin/env bash
set -e

# Homebrew can only be installed on *nix systems
[[ $UNIX ]] || return 0

# If home brew is already installed, skip this script
command_exists brew && return 0

# Has SKIP_HOMEBREW_INSTALL been specified
[[ -z "$SKIP_HOMEBREW_INSTALL" ]] && INSTALL_HOMEBREW=0

# If homebrew is not to be installed, then skip the install
[[ $INSTALL_HOMEBREW ]] || {
    line "Homebrew installation skipped..."
    return 0
}

# Download and run the install script
line "Downloading and installing Homebrew..."
[[ $MACOS ]] && /usr/bin/ruby -e $(curl -fsSL "https://raw.githubusercontent.com/Hombrew/install/master/install")
[[ $LINUX ]] && sh -c $(curl -fsSL "https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh")