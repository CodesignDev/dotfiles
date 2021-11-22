#!/usr/bin/env bash

# Current directory
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install latest ruby version
if command_exists rbenv; then

    # Get the latest ruby version currently availble
    RUBY_LATEST_VERSION=$(rbenv install --list-all | grep -v - | tail -1)

    # Install the latest version if it isn't already installed
    rbenv versions --bare | grep $QUIET_FLAG_GREP $RUBY_LATEST_VERSION || {
        line "Installing latest ruby ($RUBY_LATEST_VERSION) via rbenv..."
        rbenv install $RUBY_LATEST_VERSION
    }
fi
