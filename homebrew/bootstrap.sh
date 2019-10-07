#!/usr/bin/env bash
set -e

# If homebrew is not installed, skip this section
command_exists brew || {
    warning "Homebrew is not installed. Skipping taps."
    return 0
}

# Skip brew auto update for a bit
export HOMEBREW_NO_AUTO_UPDATE=1

# Set up some taps for homebrew using brew bundle
line "Tapping Homebrew repositories..."

# Install the relevant taps
brew tap 'homebrew/core'
brew tap 'homebrew/cask'
brew tap 'homebrew/bundle'

# If we are on OS X, add homebrew/services as well
[[ $MACOS ]] && brew tap 'homebrew/services'

# Run a brew update
line "Updating Homebrew..."
brew update