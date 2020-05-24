#!/usr/bin/env bash

# This is only for macOS
is_macos || return 0

# Allow homebrew to be installed
INSTALL_HOMEBREW=1

# Get the macOS version
MACOS_VERSION="$(sw_vers -productVersion)"

# Get the macOS version as a numeric value
printf -v MACOS_VERSION_NUMERIC "%02d%02d%02d" ${MACOS_VERSION//./ }

# Paths to use to detect if CLT is installed
CLT_DETECT_GIT_PATH="/Library/Developer/CommandLineTools/usr/bin/git"
CLT_DETECT_HEADER_PATH="/usr/include/iconv.h"

# Find out what to check depending on macOS version.
# This is a function as it gets used again
clt_should_be_installed() {
    if [[ "$MACOS_VERSION_NUMERIC" -gt "101300" ]]; then
        ! [[ -e $CLT_DETECT_GIT_PATH ]]
    else
        ! [[ -e $CLT_DETECT_GIT_PATH ]] ||
        ! [[ -e $CLT_DETECT_HEADER_PATH ]]
    fi
}

# Test if the CLT bundled git is installed
if clt_should_be_installed; then

    # Command Line Tools need installing
    line "Installing Command Line Tools for macOS..."

    # Ask for sudo permissions
    line "Asking for sudo permissions..."
    sudo_init

    # Place the placeholder file
    CLT_PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    sudo_askpass touch "$CLT_PLACEHOLDER"

    # Specifics for 10.9
    if [[ "$MACOS_VERSION_NUMERIC" -ge "100900" ]] && [[ "$MACOS_VERSION_NUMERIC" -lt "101000" ]]; then
        CLT_MACOS_VERSION="Mavericks"
    else
        CLT_MACOS_VERSION="$(echo "$MACOS_VERSION" | grep -E -o "10\\.\\d+")"
    fi

    # Specifics for 10.13 and above
    if [[ "$MACOS_VERSION_NUMERIC" -ge "101300" ]]; then
        CLT_SORT="sort -V"
    else
        CLT_SORT="sort"
    fi

    # Get the package from software update
    CLT_PACKAGE=$(softwareupdate -l | \
                  grep -B 1 -E "Command Line (Developer|Tools)" | \
                  awk -F"*" '/& +\/ {print $2}' | \
                  sed 's/^ *//' | \
                  grep "$CLT_MACOS_VERSION" | \
                  $CLT_SORT | \
                  tail -n1)

    # Execute the install and cleanup the placeholder
    line "Installing ${CLT_PACKAGE}..."
    sudo_askpass softwareupdate -i "$CLT_PACKAGE"
    sudo_askpass rm -f "$CLT_PLACEHOLDER"

    # Switch to the installed CLT
    sudo_askpass xcode-select --switch /Library/Developer/CommandLineTools
fi

# Test to see if the CLT installed successfully
if clt_should_be_installed && is_interactive input; then

    # Install the old fashioned way so inform the user that they will get a popup
    line "Installing the Command Line Tools (expect a GUI popup)..."
    sudo_askpass xcode-select --install
    indent "Press any key when the installation has completed."

    # Wait for user input
    read -rsp -n1 key

    # Switch to the installed version of CLT
    sudo_askpass xcode-select --switch /Library/Developer/CommandLineTools
fi

# Test to see if the Xcode license has been accepted.
if /usr/bin/xcrun clang 2>&1 | grep $QUIET_FLAG_GREP license; then
    line "Asking for Xcode license confirmation..."
    sudo_askpass xcodebuild -license
fi
