#!/usr/bin/env bash

# Check if git lfs is already installed
if ! command_exists git-lfs; then

    # For apt
    packages is_supported apt && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo_askpass bash

    # Install git-lfs
    packages install git-lfs

fi

# Check if git lfs has now been installed
if command_exists git-lfs; then

    # Complete the installation of lfs
    git lfs install

fi
