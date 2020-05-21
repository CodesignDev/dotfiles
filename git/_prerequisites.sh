#!/usr/bin/env bash

# Install pre-requisite software (linux only for now as homebrew has not been installed yet
restrict_package_managers apt | install_package git

# Is git installed?
command_exists git || {
    error "'git' could not be installed. Please ensure that this has been installed."
    return 1
}

# Local variables
GIT_CREDENTIAL_MANAGER=
GIT_CREDENTIAL_MANAGER_COMMAND=

# Console output
line "Setting up git credential manager..."

# OS X specific
if [[ $MACOS == 1 ]]; then

    # Test if the osx credential manager is installed
    if git credential-osxkeychain 2>&1 | grep $QUIET_FLAG_GREP "git.credential-osxkeychain"; then

        # OSX Credential Manager details
        GIT_CREDENTIAL_MANAGER="osxkeychain"
        GIT_CREDENTIAL_MANAGER_COMMAND="credential-osxkeychain"
    fi
fi

# Linux specific
if [[ $LINUX == 1 ]]; then

    # Check if the goto linux git credential manager is setup
    if ! git credential-libsecret 2>&1 | grep $QUIET_FLAG_GREP "git.credential-libsecret"; then

        # Log the current action
        line "Building git credential manager for Linux..."

        # Install some apt packages (We're skipping the command exists check here as these are libs)
        restrict_package_managers apt | install_package libsecret-1-0 libsecret-1-dev

        # Find the source folder and the git-core folder
        local CREDENTIAL_MANAGER_SOURCE_DIR=$(dirname $(list_installed_package_files_apt git | grep "git-credential-libsecret.c"))
        local CREDENTIAL_MANAGER_RESULT_DIR=$(dirname $(list_installed_package_files_apt git | grep "git-credential-cache$"))

        # Go to the source directory...
        cd $CREDENTIAL_MANAGER_SOURCE_DIR

        # ...build the source files...
        sudo_askpass make

        # ...copy the built file to the git-core folder so that git can find it ...
        sudo_askpass cp "git-credential-libsecret" $CREDENTIAL_MANAGER_RESULT_DIR

        # ...then change back the directory
        cd -

    fi

    # Now check see if the libseret credential manager is there
    if git credential-libsecret 2>&1 | grep $QUIET_FLAG_GREP "git.credential-libsecret"; then

        # Our Credential Manager details
        GIT_CREDENTIAL_MANAGER="libsecret"
        GIT_CREDENTIAL_MANAGER_COMMAND="credential-libsecret"
    fi
fi

# Do we have a credential manager set?
if [[ $GIT_CREDENTIAL_MANAGER ]]; then

    # Is the selected credential manager set in the global git config
    if [[ "$(git config --global credential.helper)" != "$GIT_CREDENTIAL_MANAGER" ]]; then

        # If not, set this credential manager in the global gitconfig file
        git config --global credential.helper $GIT_CREDENTIAL_MANAGER

    fi
fi

# TODO: Get and store github token
