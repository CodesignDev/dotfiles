#!/usr/bin/env bash

# Is homebrew installed
brew_required() {
    if [[ $UNIX == 1 ]]; then
        command_exists brew || {
            [[ $MACOS == 1 ]] && BREW_SOFTWARE="Homebrew"
            [[ $LINUX == 1 ]] && BREW_SOFTWARE="Linuxbrew"
            warning "$BREW_SOFTWARE needs to be installed first. Please install this and then re-run the script."
            return 1
        }
    fi
}

# Tries to install a package via brew if possible
brew_install() {
    local PACKAGES=($@)

    if [[ $UNIX == 1 ]]; then
        command_exists brew || return
        line "Installing $PACKAGES..."
        brew install $PACKAGES
    fi
}

# Tried to install a package via apt-get if possible
apt_install() {
    local PACKAGES=($@)

    if [[ $UNIX == 1 ]]; then
        if [[ $LINUX == 1 ]]; then
            for PACKAGE in ${PACKAGES[@]}; do

                is_package_installed_apt $PACKAGE && {
                    line "Skipping Installation of $PACKAGE... Already installed."
                    continue
                }

                line "Installing $PACKAGE..."
                sudo_askpass DEBIAN_FRONTEND=noninteractive apt-get install -y $QUIET_FLAG_APT $PACKAGE
            done
        else
            return 1
        fi
    fi
}

# Update brew
brew_update() {
    [[ $UNIX == 1 ]] || return
    command_exists brew || return

    line "Updating Homebrew..."
    brew update
}

# Update apt
apt_update() {
    [[ $LINUX == 1 ]] || return
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
    local REPO=$1

    [[ $UNIX == 1 ]] || return
    command_exists brew || return
    brew tap | grep $QUIET_FLAG_GREP $REPO || {
        line "Adding brew tap '$REPO'..."
        brew tap "$REPO"
    }
}

apt_add_repo() {
    local REPO_URL=$1
    local REPO_DATA=$2
    local GPGKEY=$3
    local REPO_NAME=$4

    [[ $LINUX == 1 ]] || return
    command_exists apt || return

    install_apt_repo_prerequisites

    line "Adding apt repository '$REPO_URL'..."
    curl -s $GPGKEY | sudo_askpass apt-key add -
    echo "deb $REPO_URL $REPO_DATA" | sudo_askpass tee -a /etc/apt/sources.list.d/$REPO_NAME.list

    apt_update
}

# Wrapper for checking the command exists and then trying to install using the relevant package manager
check_and_install() {

    # Get variables
    local COMMAND=$1
    local PACKAGE=${2:-$COMMAND}
    local MANAGER=${3}

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
    command_exists $COMMAND || $INSTALL_FUNC $PACKAGE
}

# Helper to check if a set of programs are already installed, and if not install them
# If this command is called without a package manager specified (parameter 3), then
# the default package manager for the OS will be used, which will be apt for linux and
# brew for OS X
# If a package manager is specified, and is not valid for the OS, then the alternative
# will be used instead. If no package managers are valid, then this will exit with an error
install_prerequisites() {

    # Get variables
    local MANAGER=$1
    local PACKAGES=(${@:2})

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

# Install prerequisites for adding apt repositories
install_apt_repo_prerequisites() {

    local CURL_INSTALLED=0
    local APT_HTTPS_TRANSPORT_INSTALLED=0
    local APT_HAS_HTTPS_BUILTIN=0

    # Both curl and apt-transport-https are required to install apt repos
    # curl is required to download GPG keys
    # apt-transport-https is required to enable https transport for repos
    [[ $(is_package_installed_apt curl) ]] && CURL_INSTALLED=1
    [[ $(is_package_installed_apt apt-transport-https) ]] && APT_HTTPS_TRANSPORT_INSTALLED=1

    APT_VERSION=$(apt --version | awk '{print $2}')
    dpkg --compare-versions "1.5" "lt" "$APT_VERSION" && APT_HAS_HTTPS_BUILTIN=1

    if [[ $CURL_INSTALLED == 1 ]] && ( [[ $APT_HAS_HTTPS_BUILTIN == 1 ]] || [[ $APT_HTTPS_TRANSPORT_INSTALLED == 1 ]] ); then
        return 0
    fi

    line "Installing prerequisites for adding apt repositories..."

    [[ $CURL_INSTALLED == 1 ]] || apt_install curl

    [[ $APT_HAS_HTTPS_BUILTIN == 1 ]] && return 0
    [[ $APT_HTTPS_TRANSPORT_INSTALLED == 1 ]] || apt_install apt-transport-https

    return 0
}

# Check if package manager is valid
VALID_PACKAGE_MANAGERS=(apt brew)
package_manager_is_valid() {

    # Check that the requested package manager is one of the valid ones
    local IS_VALID=0
    for MANAGER in "${VALID_PACKAGE_MANAGERS[@]}"; do
        if [[ $MANAGER == $1 ]]; then
            IS_VALID=1
            break
        fi
    done

    # Check that the package manager exists
    command_exists $1 && IS_INSTALLED=1

    [[ $IS_VALID == 1 ]] && [[ $IS_INSTALLED == 1 ]]
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
    local MANAGER=$1
    local PACKAGE=$2

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
    brew list | grep $QUIET_FLAG_GREP "$PACKAGE$" 2>/dev/null
}

# Checks if package is installed via apt
is_package_installed_apt() {
    local PACKAGE=$1

    command_exists apt || return 1
    dpkg --get-selections | awk '{print $1}' | grep $QUIET_FLAG_GREP "$PACKAGE$" 2>/dev/null
}

# Lists files that are part of a package, delegates to the relevant package manager
list_installed_package_files() {
    local MANAGER=$1
    local PACKAGE=$2

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
