#!/usr/bin/env bash

# Current directory
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install latest ruby version
if $(command_exists pyenv); then

    # Get the latest python 2 and 3 versions currently availble
    PYTHON_3_LATEST_VERSION=$(pyenv install --list | sed 's/^  //' | grep -v - | grep -v 'dev\|a\|b' | grep '^3' | tail -1)
    PYTHON_2_LATEST_VERSION=$(pyenv install --list | sed 's/^  //' | grep -v - | grep -v 'dev\|a\|b' | grep '^2' | tail -1)

    # Install the latest v3 version if it isn't already installed
    pyenv versions --bare | grep $QUIET_FLAG_GREP $PYTHON_3_LATEST_VERSION || {
        line "Installing latest v3 python ($PYTHON_3_LATEST_VERSION) via pyenv..."
        pyenv install $PYTHON_3_LATEST_VERSION
    }

    # Install the latest v2 version if it isn't already installed
    pyenv versions --bare | grep $QUIET_FLAG_GREP $PYTHON_2_LATEST_VERSION || {
        line "Installing latest v2 python ($PYTHON_2_LATEST_VERSION) via pyenv..."
        pyenv install $PYTHON_2_LATEST_VERSION
    }
fi
