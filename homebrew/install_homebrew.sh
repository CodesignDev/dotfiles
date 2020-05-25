#!/usr/bin/env bash

# Homebrew can only be install on *nix systems
is_unix || return 0

# If homebrew installed is requested to be skipped
[[ -z $SKIP_HOMEBREW_INSTALL ]] && INSTALL_HOMEBREW=0

# Check if homebrew needs installing (linux only)
if is_linux; then
    INSTALL_HOMEBREW=${INSTALL_HOMEBREW_ON_LINUX:-0}
fi

# If homebrew is not to be installed, bail
if [[ "$INSTALL_HOMEBREW" == "0" ]]; then

    line "Homebrew installation skipped..."
    return 0
fi

# Check if homebrew is already installed
HOMEBREW_ALREADY_INSTALLED=0
command_exists brew && HOMEBREW_ALREADY_INSTALLED=1

# Prevent homebrew from performing auto updates for a bit
export HOMEBREW_NO_AUTO_UPDATE=1

# If homebrew isn't installed, download and run the install script
if [[ "$HOMEBREW_ALREADY_INSTALLED" == "0" ]]; then

    # Run the installer
    line "Downloading and installing Homebrew..."
    /bin/bash -c "$(curl -fsSL "https://raw.githubusercontent.com/Homebrew/install/master/install.sh")"

    # Update the internal list of managed package managers
    update_managed_package_managers

fi

# Add some default repos / taps
line "Installing Homebrew Taps and Extensions..."

# Install some core taps
packages restrict brew | packages add_repository 'homebrew/core'
packages restrict brew | packages add_repository 'homebrew/bundle'

# Install some macos specific taps
if is_macos; then
    packages restrict brew | packages add_repository 'homebrew/cask'
    packages restrict brew | packages add_repository 'homebrew/services'
fi

# Perform a homebrew update
packages restrict brew | packages update

# Install some core packages
packages restrict brew | packages install coreutils git jq
