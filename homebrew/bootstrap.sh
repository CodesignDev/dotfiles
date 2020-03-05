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
line "Installing Homebrew Taps and Extensions..."

# Install the relevant taps
brew_add_repo 'homebrew/core'
brew_add_repo 'homebrew/bundle'

# If we are on OS X, add homebrew/casl and homebrew/services as well
[[ $MACOS == 1 ]] && brew_add_repo 'homebrew/cask'
[[ $MACOS == 1 ]] && brew_add_repo 'homebrew/services'

# Run a brew update
line "Updating Homebrew..."
brew update
