#!/usr/bin/env bash

# If homebrew is not installed, skip this section
command_exists brew || {
    return 0
}

# Skip brew auto update for a bit
export HOMEBREW_NO_AUTO_UPDATE=1

# Set up some taps for homebrew using brew bundle
line "Installing Homebrew Taps and Extensions..."

# Install the relevant taps
add_package_repository 'homebrew/core'
add_package_repository 'homebrew/bundle'

# If we are on OS X, add homebrew/cask and homebrew/services as well
[[ $MACOS == 1 ]] && add_package_repository 'homebrew/cask'
[[ $MACOS == 1 ]] && add_package_repository 'homebrew/services'

# Run a brew update
line "Updating Homebrew..."
brew update

# Install some default packages
install_package coreutils git jq
