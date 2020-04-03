#!/usr/bin/env bash

# Is antibody installed
if ! $(command_exists antibody); then

    # Attempt to install antibody via homebrew
    if command_exists brew; then

        # Check for the tap
        brew_add_repo getantibody/tap

        # Install
        brew_install antibody

    # Homebrew not available
    else

        # Install via the official script instead
        curl -sL https://git.io/antibody | sudo_askpass sh -s -- -b /usr/local/bin

    fi
fi
