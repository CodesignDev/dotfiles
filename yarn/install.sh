#!/usr/bin/env bash

# Is yarn not installed
if ! $(command_exists yarn); then

    # Add the repo to apt if needed
    apt_add_repo "https://dl.yarnpkg.com/debian/" "stable main" "https://dl.yarnpkg.com/debian/pubkey.gpg" "yarn"

    # Install the yarn command
    check_and_install yarn
fi
