#!/usr/bin/env bash
set -e

# If homebrew is not installed, skip this section
command_exists brew || {
    warning "Homebrew is not installed so skipping taps."
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
# HOMEBREW_TAP_BUNDLE_DIR=$(mktemp -d)
# HOMEBREW_TAP_BUNDLE=$(mktemp "$HOMEBREW_TAP_BUNDLE_DIR"/brew-tap-bundle-XXXXXXXX)
# echo "tap 'homebrew/core'" >> $HOMEBREW_TAP_BUNDLE
# echo "tap 'homebrew/cask'" >> $HOMEBREW_TAP_BUNDLE

# If we are on OS X, add homebrew/services as well
[[ $MACOS ]] && brew tap 'homebrew/services' #echo "tap 'homebrew/services'" >> $HOMEBREW_TAP_BUNDLE

# Install the taps
# brew bundle -v --file=- < $HOMEBREW_TAP_BUNDLE

# # Cleanup
# [[ -f $HOMEBREW_TAP_BUNDLE ]] && rm -f $HOMEBREW_TAP_BUNDLE
# [[ -d $HOMEBREW_TAP_BUNDLE_DIR ]] && rm -rf $HOMEBREW_TAP_BUNDLE_DIR

# Run a brew update
line "Updating Homebrew..."
brew update