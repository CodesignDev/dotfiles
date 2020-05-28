#!/usr/bin/env bash

# Current directory
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# go default install directory
GOROOT="/usr/local/go"

# Is go already installed
if ! $(command_exists go); then

    # Attempt to install pyenv via brew
    if ! packages restrict brew | packages install go; then

        # Check if a previous version of go is installed
        if [[ -d $GOROOT ]]; then

            # Delete previous installs
            line "Removing previous installed versions of go..."
            sudo_askpass rm -rf $GOROOT

        fi

        # Automatic install failed, so we are doing this manually instead
        line "Locating go version..."

        # Temp folder to store the downloaded files
        GO_DL_DIR=$(mktemp -dt golang-dl.XXXXXXXX)

        # Get the download url from the google page
        GO_URL_REGEX="https://dl.google.com/go/go[0-9\.]+\.$OS-$OS_ARCH.tar.gz"
        GO_URL=$(curl -fsSL https://golang.org/dl/ | grep -oE $GO_URL_REGEX | head -n 1)
        GO_VERSION=$(echo $GO_URL | grep -oE 'go[0-9\.]+' | grep -oE '[0-9\.]+' | head -c -2)

        # Download the relevant go archive
        line "Downloading go v$GO_VERSION..."
        curl -fsSL "$GO_URL" > "$GO_DL_DIR/go$GO_VERSION.tar.gz"

        # Extract the downloaded file
        line "Installing go v$GO_VERSION..."
        sudo_askpass tar zxf "$GO_DL_DIR/go$GO_VERSION.tar.gz" -C $(dirname $GOROOT)

        # Add go to path
        export PATH="$GOROOT/bin:$PATH"

        # Cleanup
        rm -rf $GO_DL_DIR/* $GO_DL_DIR
    fi
fi
