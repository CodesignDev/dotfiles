#!/usr/bin/env bash

# Is yarn not installed
if ! $(command_exists yarn); then

    # Add the repo to apt if needed
    restrict_package_managers apt | add_package_repository "yarn" "https://dl.yarnpkg.com/debian/" "stable" "main" "https://dl.yarnpkg.com/debian/pubkey.gpg"

    # Install the yarn command
    install_package yarn
fi
