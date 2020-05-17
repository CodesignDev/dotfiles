#!/usr/bin/env bash

# Script that has a utility to save a users password temporarily for long running
# processes that need sudo permissions

# Wrapper around sudo --askpass to use our custom saved password script
sudo_askpass() {
    if [ -n "$SUDO_ASKPASS" ]; then
        sudo --askpass "$@"
    else
        sudo_init
        sudo "$@"
    fi
}

sudo_init() {

    # Don't bother initialising if script is not interactive
    if [ -z "$IS_INTERACTIVE" ]; then
        return
    fi

    # If we have a SUDO_ASKPASS already, then skip initialising
    if [ -n "$SUDO_ASKPASS" ]; then
        return
    fi

    # Local variables
    local SUDO_PASSWORD SUDO_PASSWORD_SCRIPT

    # Check if we don't have sudo credentials
    if [[ ! $(sudo --validate --non-interactive &> /dev/null) ]]; then

        # Do an infinite loop to get the users password
        while true; do

            # Read the password
            line "Enter your passowrd (for sudo)"
            read -rsp "" SUDO_PASSWORD

            # Check if against sudo to see if its valid
            if sudo --validate --stdin 2> /dev/null <<<"$SUDO_PASSWORD"; then
                break
            fi

            # Reset the variable and try again
            unset SUDO_PASSWORD
            indent "Password incorect. Please try again."
        done

        # Disable debug
        debug_clear

        # Set up the SUDO_ASKPASS script
        SUDO_PASSWORD_SCRIPT="$(cat <<BASH
#!/bin/bash
echo "$SUDO_PASSWORD"
BASH
)"

        # Clear the password variable as its not needed anymore
        unset SUDO_PASSWORD

        # Create the file which will store the script
        SUDO_ASKPASS_DIR="$(mktemp -d)"
        SUDO_ASKPASS="$(mktemp "$SUDO_ASKPASS_DIR"/df-askpass-XXXXXXXX)"

        # Set up permissions on the sudo_askpass script
        chmod 700 "$SUDO_ASKPASS_DIR" "$SUDO_ASKPASS"

        # Store the script in the file
        bash -c "cat > '$SUDO_ASKPASS'" <<<"$SUDO_PASSWORD_SCRIPT"

        # Perform some cleanup
        unset SUDO_PASSWORD_SCRIPT

        # Store a copy of the script so that it can be checked during cleanup
        DF_SUDO_ASKPASS=$SUDO_ASKPASS

        # Reset some debug
        debug_reset

        # Export the necessary variables
        export SUDO_ASKPASS
    fi
}

sudo_refresh() {

    # Clear debug mode
    debug_clear

    # Refresh the timer on sudo if we already have a password script, if not set it up
    if [ -n "$SUDO_ASKPASS" ]; then
        sudo --askpass --validate
    else
        sudo_init
    fi

    # Re-enable debug
    debug_reset
}

sudo_cleanup() {

    # Is an password script defined and more importantly is it our password script
    if [[ -n $SUDO_ASKPASS && "$SUDO_ASKPASS" == "$DF_SUDO_ASKPASS" ]]; then
        sudo_askpass rm -rf "$SUDO_ASKPASS"
        sudo --reset-timestamp
    fi
}

# Clear the sudo timer to force a password
sudo --reset-timestamp

# Initialise the sudo pass
# sudo_init

# Execute our cleanup script when script exits
if function_exists hook; then
    hook cleanup sudo_cleanup
else
    trap "sudo_cleanup" EXIT
fi
