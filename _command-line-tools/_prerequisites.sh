#!/usr/bin/env bash
set -e

# This script is in a folder called command-line-tools so that it gets called
# first during the prereg section of the bootstrap process. This is because a lot
# of the other scripts rely on the programs being installed that are included in
# the OS X Command Line Tools like git.

# If these dotfiles were installed using a system like strap or my
# dotfiles-installer then the Command Line Tools  will most likely already have
# been installed.

# This is only for OS X
[[ $MACOS == 1 ]] || return 0

# Allow homebrew to be installed
INSTALL_HOMEBREW=1

# Get the OS X version
MACOS_VERSION="$(sw_vers -productVersion)"

# Test if the CLT bundled git is installed
if ! [ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]; then

    # Command Line Tools need installing
    line "Installing Command Line Tools..."

    # Place the placeholder file
    CLT_PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    sudo_askpass touch "$CLT_PLACEHOLDER"

    # Get the OS X version as a numeric value
    printf -v MACOS_VERSION_NUMERIC "%02d%02d%02d" ${MACOS_VERSION//./ }

    # Specifics for 10.9
    if [ "$MACOS_VERSION_NUMERIC" -ge "100900" ] && [ "$MACOS_VERSION_NUMERIC" -lt "101000" ]; then
        CLT_MACOS_VERSION="Mavericks"
    else
        CLT_MACOS_VERSION="$(scho "$MACOS_VERSION" | grep -E -o "10\\.\\d+")"
    fi

    # Specifics for 10.13 and above
    if [ "$MACOS_VERSION_NUMERIC" -ge "101300" ]; then
        CLT_SORT="sort -V"
    else
        CLT_SORT="sort"
    fi

    # Get the package from software update
    CLT_PACKAGE=$(softwareupdate -l | \
                  grep -B 1 -E "Command Line (Developer|Tools)" | \
                  awk -F"*" '/& +\/ {print $2}' | \
                  sed 's/^ *//' | \
                  grep "$CLT_MACOS_VERSION" |
                  $CLT_SORT |
                  tail -n1)

    # Execute the install and cleanup the placeholder
    line "Installing ${CLT_PACKAGE}..."
    sudo_askpass softwareupdate -i "$CLT_PACKAGE"
    sudo_askpass rm -f "$CLE_PLACEHOLDER"

    # Switch to the installed CLT
    sudo_askpass xcode-select --switch /Library/Developer/CommandLineTools

    # Test to see if the CLT installed successfully
    if ! [ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]; then

        # Install the old fashioned way so inform the user that they will get a popup
        line "Installing the Command Line Tools (expect a GUI popup)..."
        sudo_askpass xcode-select --install
        indent "Press any key when the installation has completed."

        # Wait for user input
        read -rsp -n1 key

        # Switch to the installed version of CLT
        sudo_askpass xcode-select --switch /Library/Developer/CommandLineTools
    fi
fi

# Test to see if the Xcode license has been accepted.
if /usr/bin/xcrun clang 2>&1 | grep $QUIET_FLAG_GREP license; then
    line "Asking for Xcode license confirmation..."
    sudo_askpass xcodebuild -license
fi