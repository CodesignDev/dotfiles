#!/usr/bin/env bash

export OS_DISTRIBUTION="Unknown"

detect_distribution() {

    # Check if lsb_release is a valid command
    if ! command_exists lsb_release; then
        return 0
    fi

    # If $DIST_CODE isn't defined
    if [[ -z $DIST_CODE ]]; then

        # Get the distributor codename from lsb_release
        OS_DISTRIBUTION=$(lsb_release -cs)
        export OS_DISTRIBUTION

    # Otherwise use the value defined in $DIST_CODE
    else
        OS_DISTRIBUTION=$DIST_CODE
        export OS_DISTRIBUTION
    fi
}
