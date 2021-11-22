#!/usr/bin/env bash

# Install git
packages install git

# Check if git has been installed
if ! command_exists git; then
    error "'git' could not be installed. Please install this and then run this script again."
    exit 1
fi

# Check if git has already been configured
if [[ "$(git config --global dotfiles.configured)" == "true" ]]; then
    return 0
fi

# Some local variables
GIT_CREDENTIAL_MANAGER=

# Status message
line "Setting up git..."

# macOS Specific
if is_macos; then

    # Check for the osx keychain credential manager
    if git credential-osxkeychain 2>&1 | grep $QUIET_FLAG_GREP "git.credential-osxkeychain"; then

        # OSX Keychain credential manager
        GIT_CREDENTIAL_MANAGER="osxkeychain"
    fi

# Linux specific
elif is_linux; then

    # WSL flavoured linux
    if is_wsl; then

        # Find if git installed on the host machine
        local WSL_HOST_GIT_PATH="$(wsl_where git)"
        local WSL_HOST_GIT_CREDENTIAL_MANAGER_PATH

        # Remove the executable from the git path
        WSL_HOST_GIT_PATH="$(wsl_dirname "$WSL_HOST_GIT_PATH")"

        # If git is installed on the host, try and find the credential manager
        if [[ -n $WSL_HOST_GIT_PATH ]]; then

            # Try and find the git credential manager by searching each directory
            while [[ "$WSL_HOST_GIT_PATH" == *'\'* ]]; do

                # Search for the git-credential-manager or git-credential-manager-core in the current folder
                WSL_HOST_GIT_CREDENTIAL_MANAGER_PATH="$(wsl_find "$WSL_HOST_GIT_PATH" "git-credential-manager.exe" 2>/dev/null)"
                WSL_HOST_GIT_CREDENTIAL_MANAGER_CORE_PATH="$(wsl_find "$WSL_HOST_GIT_PATH" "git-credential-manager-core.exe" 2>/dev/null)"

                # If we have a result, break out of the loop
                [[ -n "$WSL_HOST_GIT_CREDENTIAL_MANAGER_PATH" || -n "$WSL_HOST_GIT_CREDENTIAL_MANAGER_CORE_PATH" ]] && break

                # Move up a directory
                WSL_HOST_GIT_PATH="$(wsl_dirname "$WSL_HOST_GIT_PATH")"

            done

            # Get the relevant credential manager path
            WSL_GIT_CREDENTIAL_MANAGER="$WSL_HOST_GIT_CREDENTIAL_MANAGER_PATH"
            [[ -z "$WSL_GIT_CREDENTIAL_MANAGER" && -n "$WSL_HOST_GIT_CREDENTIAL_MANAGER_CORE_PATH" ]] && WSL_GIT_CREDENTIAL_MANAGER="$WSL_HOST_GIT_CREDENTIAL_MANAGER_CORE_PATH"

            # Convert the WSL path to a linux one and escape it
            WSL_GIT_CREDENTIAL_MANAGER="$(wsl_path "$WSL_GIT_CREDENTIAL_MANAGER")"
            WSL_GIT_CREDENTIAL_MANAGER="$(wsl_escape_path "$WSL_GIT_CREDENTIAL_MANAGER")"

            # Assign the path to git
            GIT_CREDENTIAL_MANAGER="$WSL_GIT_CREDENTIAL_MANAGER"

        # Git isn't install on the host, so use the file based credential manager instead
        else

            # Set the credential manager
            # The store credential manager is being used here as libsecret won't work on WSL
            # based linux without a UI running
            GIT_CREDENTIAL_MANAGER="store"

        fi

    # Vanilla linux
    else

        # Check if libsecret credential manager exists
        if ! git credential-libsecret 2>&1 | grep $QUIET_FLAG_GREP "git.credential-libsecret"; then

            # Libsecret isn't installed, so let's build it
            line "Building git credential manager for Linux..."

            # Install the libsecret packages
            packages restrict apt | packages install libsecret-1-0 libsecret-1-dev

            # Find the location of the git and git-core folder
            local LIBSECRET_CRED_MGR_SOURCE_DIR=$(dirname $(packages list_files git | grep "git-credential-libsecret.c"))
            local LIBSECRET_CRED_MGR_RESULT_DIR=$(dirname $(packages list_files git | grep "git-credential-cache$"))

            # Go to the source directory...
            cd $LIBSECRET_CRED_MGR_SOURCE_DIR

            # ...build the source files...
            sudo_askpass make

            # ...copy the built files to the git-core folder so that git can find it...
            sudo_askpass cp "git-credential-libsecret" $LIBSECRET_CRED_MGR_RESULT_DIR

            # ...then change back the directory
            cd -

        fi

        # Check if the libsecret credential manager is now active
        if git credential-libsecret 2>&1 | grep $QUIET_FLAG_GREP "git.credential-libsecret"; then

            # Set the credential manager
            GIT_CREDENTIAL_MANAGER="libsecret"

        # The credential manager doesn't exist so fallback
        else

            # Libsecret doesn't exist so use store instead
            GIT_CREDENTIAL_MANAGER="store"

        fi
    fi

# Windows specific
elif is_windows; then

    true # No-op

fi

if [[ -n $GIT_CREDENTIAL_MANAGER ]]; then

    # Check if the selected credential manager is set in the global git config
    if [[ "$(git config --global credential.helper)" != "$GIT_CREDENTIAL_MANAGER" ]]; then

        # Set the credential manager as it isn't set
        git config --global credential.helper "$GIT_CREDENTIAL_MANAGER"

    fi
fi

# Add a flag to the git config to say that it has been configured
git config --global dotfiles.configured true
