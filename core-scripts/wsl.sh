#!/usr/bin/env bash

# Only register these functions if running in WSL
is_wsl || return 1

# Try and find a binary on the windows host machine
wsl_where() {
    local COMMAND=$1

    # Get the path to the where.exe command on the windows host
    local WSL_WHERE_COMMAND="$(get_command_path where.exe)"
    local WSL_PATH

    # Check if the where command path is valid
    if [[ -e $WSL_WHERE_COMMAND ]]; then
        WSL_PATH="$($WSL_WHERE_COMMAND $COMMAND)"
        WSL_PATH="$(wsl_clean_string "$WSL_PATH")"
    else
        WSL_PATH=""
    fi

    # Escape the string
    # WSL_PATH="$(wsl_escape_path "$WSL_PATH")"

    # Return the string
    echo "$WSL_PATH"
}

wsl_dirname() {
    local WSL_PATH=$1

    # Remove the last character from the path if it is a directory separator
    [[ "${WSL_PATH: -1}" == "\\" ]] && WSL_PATH="${WSL_PATH:0:-1}"

    # Attempt to remove everything up to the next directory separator
    WSL_PATH=$(echo "$WSL_PATH" | sed -e 's/\\[^\\]*$//')

    # Return the new path
    echo "$WSL_PATH"
}

wsl_find() {
    local BASE_DIRECTORY=$1
    local COMMAND_TO_FIND=$2

    # Get the path to the where.exe command on the windows host
    local WSL_WHERE_COMMAND=$(get_command_path where.exe)
    local WSL_PATH

    # Run the where command with the relevant switches
    if [[ -e "$WSL_WHERE_COMMAND" ]]; then
        WSL_PATH="$($WSL_WHERE_COMMAND /r "$BASE_DIRECTORY" "$COMMAND_TO_FIND")"
        WSL_PATH="$(wsl_clean_string "$WSL_PATH")"
    else
        WSL_PATH=""
    fi

    # Return the string
    echo "$WSL_PATH"
}

# Convert a windows path to the linux variant
wsl_path() {
    wsl_path_to_linux "$1"
}

# Convert a windows path to the linux variant
wsl_path_to_linux() {
    local COMMAND_PATH=$1

    local WSL_DRIVE_LETTER

    # If the native wslpath exists, use that instead
    if command_exists wslpath; then
        wslpath -u "$COMMAND_PATH"
        return
    fi

    # Get the drive letter
    WSL_DRIVE_LETTER=$(echo "$COMMAND_PATH" | grep -o '[A-Za-z]:')

    # Convert the path to a linux version
    COMMAND_PATH=${COMMAND_PATH/$WSL_DRIVE_LETTER/}
    COMMAND_PATH=$(echo "$COMMAND_PATH" | tr '\\' '/')

    # Create the path
    WSL_DRIVE_LETTER="$(echo "$COMMAND_PATH" | grep -o '[A-Za-z]' | tr '[:upper:]' '[:lower:]')"
    WSL_DRIVE_LETTER="/mnt/$WSL_DRIVE_LETTER"

    echo "$WSL_DRIVE_LETTER$COMMAND_PATH"
}

# Convert a linux path to a windows variant
wsl_path_to_windows() {
    local COMMAND_PATH=$1

    local WSL_DRIVE_LETTER
    local WSL_SERVER_PATH="//wsl$"
    local WSL_COMMAND_PATH

    # If the native wslpath exists, use that instead
    if command_exists wslpath; then
        wslpath -w "$COMMAND_PATH"
        return
    fi

    # Does the linux path have a windows drive path
    if echo "$COMMAND_PATH" | grep $QUIET_FLAG_GREP '^/mnt/[A-Za-z]/'; then
        WSL_DRIVE_LETTER=$(echo "$COMMAND_PATH" | grep -o '^/mnt/[A-Za-z]/' | grep -o '^/mnt/[A-Za-z]')
        COMMAND_PATH=${COMMAND_PATH/$WSL_DRIVE_LETTER/}
        WSL_DRIVE_LETTER=$(echo "$WSL_DRIVE_LETTER" | sed 's/\/mnt\/\([A-Za-z]\)\//\1/g' | tr '[:lower:]' '[:upper:]')
        WSL_DRIVE_LETTER="$WSL_DRIVE_LETTER:"
    else
        WSL_DRIVE_LETTER="$WSL_SERVER_PATH/$WSL_DISTRO_NAME"
    fi

    WSL_COMMAND_PATH="$WSL_DRIVE_LETTER$COMMAND_PATH"
    WSL_COMMAND_PATH="$(echo "$WSL_COMMAND_PATH" | tr '/' '\')"

    echo "$WSL_COMMAND_PATH"
}

wsl_clean_string() {
    local WSL_PATH=$1

    # Remove trailing linefeeds because windows is weird
    WSL_PATH="$(echo "$WSL_PATH" | sed 's/\r//g')"

    # Return the string
    echo "$WSL_PATH"
}

wsl_escape_path() {
    local WSL_PATH=$1

    # Run the path through printf to escape it
    WSL_PATH="$(printf "%q" "$WSL_PATH")"

    # Return the string
    echo "$WSL_PATH"
}
