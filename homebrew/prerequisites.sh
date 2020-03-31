#!/usr/bin/env bash
set -e

# Homebrew can only be installed on *nix systems
[[ $UNIX == 1 ]] || return 0

# If home brew is already installed, skip this script
command_exists brew && return 0

# Make homebrew installation on linux optional
INSTALL_LINUXBREW=${INSTALL_HOMEBREW_ON_LINUX:-0}
[[ $LINUX == 1 ]] && [[ $INSTALL_LINUXBREW == 0 ]] && INSTALL_HOMEBREW=0

# Has SKIP_HOMEBREW_INSTALL been specified
[[ -z "$SKIP_HOMEBREW_INSTALL" ]] && INSTALL_HOMEBREW=0

# If homebrew is not to be installed, then skip the install
[[ $INSTALL_HOMEBREW ]] || {
    line "Homebrew installation skipped..."
    return 0
}

# Download and run the install script
line "Downloading and installing Homebrew..."
[[ $MACOS == 1 ]] && /usr/bin/ruby -e $(curl -fsSL "https://raw.githubusercontent.com/Hombrew/install/master/install")
[[ $LINUX == 1 ]] && sh -c $(curl -fsSL "https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh")
