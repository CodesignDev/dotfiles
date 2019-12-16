#!/usr/bin/env bash

# Is homebrew installed
brew_required() {
    if [[ $UNIX ]]; then
        command_exists brew || {
            [[ $MACOS ]] && BREW_SOFTWARE="Homebrew"
            [[ $LINUX ]] && BREW_SOFTWARE="Linuxbrew"
            warning "$BREW_SOFTWARE needs to be installed first. Please install this and then re-run the script."
            return 1
        }
    fi
}

# Tries to install a package via brew if possible
brew_install() {
    PACKAGE=$1
    if [[ $UNIX ]]; then
        command_exists brew || return
        line "Installing $PACKAGE..."
        brew install $PACKAGE
    fi
}

# Tried to install a package via apt-get if possible
apt_install() {
    PACKAGE=$1
    if [[ $UNIX ]]; then
        if [[ $LINUX ]]; then
            line "Installing $PACKAGE..."
            sudo_askpass apt-get install -y $PACKAGE
        else
            return 1
        fi
    fi
}

# Update brew
brew_update() {
    [[ $UNIX ]] || return
    command_exists brew || return
    line "Updating Homebrew..."
    brew update
}

# Update apt
apt_update() {
    [[ $LINUX ]] || return
    command_exists apt || return
    line "Updating apt..."
    sudo_askpass apt-get update
}

# Update package managers
package_manager_update() {
    brew_update
    apt_update
}

brew_add_repo() {
    REPO=$1
    [[ $UNIX == 1 ]] || return
    command_exists brew || return
    brew tap | grep $QUIET_FLAG_GREP $REPO || {
        line "Adding brew tap '$REPO'..."
        brew tap "$REPO"
    }
}

apt_add_repo() {
    REPO_URL=$1
    REPO_DATA=$2
    GPGKEY=$3
    REPO_NAME=$4
    [[ $LINUX == 1 ]] || return
    command_exists apt || return

    line "Adding apt repository '$REPO_URL'..."
    install_apt_prerequisites curl apt-transport-https
    curl -s $2 | sudo_askpass apt-key add -
    echo "deb $REPO_URL $REPO_DATA" | sudo_askpass tee -a /etc/apt/sources.list.d/$REPO_NAME.list

    apt_update
}

# Wrapper for checking the command exists and then trying to install using the relevant package manager
check_and_install() {

    # Get variables
    COMMAND=$1
    PACKAGE=${2:-$COMMAND}
    MANAGER=${3}

    # Does the command have the format 'command:package'
    if [[ $COMMAND == *":"* ]]; then

        # Split the current command and package up
        ORIG_COMMAND=$COMMAND
        COMMAND=$(echo $ORIG_COMMAND | cut -f 1 -d :)
        PACKAGE=$(echo $ORIG_COMMAND | cut -f 2 -d :)

        # Get the manager in case its specified
        MANAGER=$(echo $ORIG_COMMAND | cut -f 3 -d :) || $MANAGER
    fi

    # Do a sanity check on $MANAGER
    package_manager_is_valid $MANAGER || MANAGER=$(package_manager_get_default)
    INSTALL_FUNC="${MANAGER}_install"

    # Finally check the command exists and if not, install it
    command_exists $1 || $INSTALL_FUNC $2
}

# Helper to check if a set of programs are already installed, and if not install them
# If this command is called without a package manager specified (parameter 3), then
# the default package manager for the OS will be used, which will be apt for linux and
# brew for OS X
# If a package manager is specified, and is not valid for the OS, then the alternative
# will be used instead. If no package managers are valid, then this will exit with an error
install_prerequisites() {

    # Get variables
    MANAGER=$1
    PACKAGES=(${@:2})

    # Was a package manager passed
    package_manager_is_valid $MANAGER || {
        MANAGER=
        PACKAGES=($@)
    }

    # Loop through each package
    for PACKAGE in "${PACKAGES[@]}"; do
        check_and_install $PACKAGE '' $MANAGER || {
            error "'$PACKAGE' could not be installed. Please install this manually and then re-run the command."
            return 1
        }
    done
}

# Wrapper for the install_prerequistites with a package manager set
install_brew_prerequisites() {
    install_prerequisites brew $@
}
install_apt_prerequisites() {
    install_prerequisites apt $@
}

# Check if package manager is valid
VALID_PACKAGE_MANAGERS=(apt brew)
package_manager_is_valid() {

    # Check that the requested package manager is one of the valid ones
    IS_VALID=0
    for MANAGER in "${VALID_PACKAGE_MANAGERS[@]}"; do
        if [[ $MANAGER == $1 ]]; then
            IS_VALID=1
            break
        fi
    done

    # Check that the package manager exists
    command_exists $1 && IS_INSTALLED=1

    [[ $IS_VALID ]] && [[ $IS_INSTALLED ]]
    return
}

# Get the first valid package manager for this OS
package_manager_get_default() {

    # Loop through all of valid package managers
    for MANAGER in "${VALID_PACKAGE_MANAGERS[0]}"; do
        if package_manager_is_valid $MANAGER; then
            echo $MANAGER
            return
        fi
    done
}

# Check if a package is installed. Delegates to the relevat package manage function
is_package_installed() {
    MANAGER=$1
    PACKAGE=$2
    
    # Was a package manager passed
    package_manager_is_valid $MANAGER || {
        MANAGER=$(package_manager_get_default)
        PACKAGES=$1
    }

    # Call the function to check files
    is_package_installed_$MANAGER $PACKAGE
}

# Checks if package is installed via homebrew
is_package_installed_brew() {
    local PACKAGE=$1

    command_exists brew || return 1
    brew list | grep $QUIET_FLAG_GREP "$PACKAGE$"
}

# Checks if package is installed via apt
is_package_installed_apt() {
    local PACKAGE=$1

    command_exists apt || return 1
    dpkg --get-selections | awk '{print $1}' | grep $QUIET_FLAG_GREP "$PACKAGE$"
}

# Lists files that are part of a package, delegates to the relevant package manager
list_installed_package_files() {
    MANAGER=$1
    PACKAGE=$2
    
    # Was a package manager passed
    package_manager_is_valid $MANAGER || {
        MANAGER=$(package_manager_get_default)
        PACKAGES=$1
    }

    # Call the function to check files
    list_installed_package_files_$MANAGER $PACKAGE
}

# Lists all files that are part of a package via homebrew
list_installed_package_files_brew() {
    local PACKAGE=$1

    command_exists brew || return 1
    brew list -v $PACKAGE 2>/dev/null
}

# Lists all files that are part of a package via apt
list_installed_package_files_apt() {
    local PACKAGE=$1

    command_exists apt || return 1
    dpkg -L $PACKAGE 2>/dev/null
}