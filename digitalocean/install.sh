#!/usr/bin/env bash

# Is doctl already installed
if ! command_exists doctl; then

    # Print a message to the console
    line "Installing doctl..."

    # Get the latest version of the digitalocean cli
    DOCTL_LATEST_VERSION=$(github_get_latest_release_version "digitalocean/doctl")
    DOCTL_VERSION_NUMBER=${DOCTL_LATEST_VERSION:1}

    # Create a temporary directory
    DOCTL_DOWNLOAD_DIR=$(mktemp -dt doctl.XXXXXXXX)

    # Download the installer
    curl -fsSL "https://github.com/digitalocean/doctl/releases/download/$DOCTL_LATEST_VERSION/doctl-$DOCTL_VERSION_NUMBER-linux-amd64.tar.gz" > $DOCTL_DOWNLOAD_DIR/doctl.tar.gz

    # Extract the archive
    tar zxvf $DOCTL_DOWNLOAD_DIR/doctl.tar.gz -C $DOCTL_DOWNLOAD_DIR

    # Move the bianry to /usr/local/bin
    sudo_askpass mv $DOCTL_DOWNLOAD_DIR/doctl /usr/local/bin

    # Cleanup
    rm -rf $DOCTL_DOWNLOAD_DIR

fi
