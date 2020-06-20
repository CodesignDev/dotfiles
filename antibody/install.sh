#!/usr/bin/env bash

# Is antibody installed
if ! command_exists antibody; then

    # Install a homebrew tap
    packages restrict brew | packages add_repository getantibody/tap

    # Attempt to install via brew if possible
    if ! packages restrict brew | packages install antibody; then

        # Install via brew failed, install via the official script instead
        curl -sL https://git.io/antibody | sudo_askpass sh -s -- -b /usr/local/bin

    fi
fi
