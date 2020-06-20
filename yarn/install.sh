#!/usr/bin/env bash

# Is yarn not installed
if ! command_exists yarn; then

    # Add the repo to apt if needed
    packages restrict apt | packages add_repository "yarn" "https://dl.yarnpkg.com/debian/" "stable" "main" "https://dl.yarnpkg.com/debian/pubkey.gpg"

    # Install the yarn command
    packages install yarn
fi
