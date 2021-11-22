#!/usr/bin/env bash

# Install latest php version
if command_exists phpenv; then

    # Get the latest stable release of php
    PHP_VERSION=$(phpenv install --list | sed 's/^  //' | grep -v - | grep -v 'dev\|a\|b\|rc\|snapshot' | tail -1)
    PHP_LATEST_VERSION=$PHP_VERSION

    # Array to hold the list of version to install
    PHP_VERSIONS=($PHP_VERSION)

    # Get 2 more previous versions of php as well
    PHP_VERSION_FILTER="a.b.c" # Dummy value to get the variable set
    while [[ ${#PHP_VERSIONS[@]} -lt 3 ]]; do

        # Add the previous version to the filter
        PHP_VERSION_FOR_FILTER=$(echo $PHP_VERSION | cut -f -2 -d .)
        PHP_VERSION_FILTER+="\|$PHP_VERSION_FOR_FILTER"

        # Get the version
        PHP_VERSION=$(phpenv install --list | sed 's/^  //' | grep -v - | grep -v 'dev\|a\|b\|rc\|snapshot' | grep -v "^$PHP_VERSION_FILTER" | tail -1)

        # Add the version to the array and filter
        PHP_VERSIONS+=($PHP_VERSION)

    done

    # Loop through and install the php versions
    for PHP_VERSION in ${PHP_VERSIONS[@]}; do

        # Message to print
        [[ "$PHP_VERSION" == "$PHP_LATEST_VERSION" ]] && LATEST_TEXT="latest " || LATEST_TEXT=""
        MESSAGE=$(printf 'Installing %2$sphp version (%1$s) via phpenv...' "$PHP_VERSION" "$LATEST_TEXT")

        # Install the specified version of php
        phpenv versions --bare | grep $QUIET_FLAG_GREP $PHP_VERSION || {
            line $MESSAGE
            phpenv install $PHP_VERSION
        }

    done

    # Set the default php version
    phpenv versions --bare | grep $QUIET_FLAG_GREP $PHP_LATEST_VERSION && phpenv global $PHP_LATEST_VERSION
fi
