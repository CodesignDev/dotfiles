#!/usr/bin/env bash

# Current directory
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# go default install directory
GOROOT="/usr/local/go"

# Is go already installed
if ! command_exists go; then

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

        # Possible prefixes for download urls
        GO_URL_PREFIXES=("/dl/" "https://golang.org/dl/" "https://dl.google.com/go/")

        # Default download host
        GO_URL_HOST="https://golang.org"

        # Download file regex
        GO_URL_REGEX="go[0-9\.]+\.$OS-$OS_ARCH.tar.gz"

        # Loop through each of the prefixes and test each one against the page
        for GO_URL_PREFIX in ${GO_URL_PREFIXES[@]}; do

            # Test for the download url
            GO_URL=$(curl -fsSL https://golang.org/dl/ | grep -oE "$GO_URL_PREFIX$GO_URL_REGEX" | head -n 1)

            # Do we have a download url?
            [[ -n "$GO_URL" ]] && break
            
        done

        # If we still don't have a download url, fail it
        if [[ -z "$GO_URL" ]]; then

            # Show an error message
            error "Unable to locate the go verison"

        else

            # Do we need to add the domain?
            echo $GO_URL | grep $QUIET_FLAG_GREP '://' || GO_URL="$GO_URL_HOST$GO_URL"

            # Temp folder to store the downloaded files
            GO_DOWNLOAD_DIR=$(mktemp -dt golang-dl.XXXXXXXX)

            # Extract the version from the download url
            GO_VERSION=$(echo $GO_URL | grep -oE 'go[0-9\.]+' | head -c -2)
            GO_VERSION_NUM=$(echo $GO_VERSION | grep -oE '[0-9\.]+')

            # Download the relevant go archive
            line "Downloading go v$GO_VERSION_NUM..."
            curl -fsSL "$GO_URL" > "$GO_DOWNLOAD_DIR/$GO_VERSION.tar.gz"

            # Extract the downloaded file
            line "Installing go v$GO_VERSION_NUM..."
            sudo_askpass tar zxf "$GO_DOWNLOAD_DIR/$GO_VERSION.tar.gz" -C $(dirname $GOROOT)

            # Add go to path
            export PATH="$GOROOT/bin:$PATH"

            # Cleanup
            rm -rf $GO_DOWNLOAD_DIR
        fi
    fi
fi
