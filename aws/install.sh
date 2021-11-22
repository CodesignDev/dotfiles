#!/usr/bin/env bash

# Is aws-cli already installed
if ! command_exists aws; then

    # Print a message to the console
    line "Installing aws cli..."

    # Create a temporary directory
    AWS_CLI_DOWNLOAD_DIR=$(mktemp -dt aws-cli.XXXXXXXX)

    # Download the installer
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" > $AWS_CLI_DOWNLOAD_DIR/awscli.zip

    # Extract the archive
    unzip $QUIET_FLAG_UNZIP "$AWS_CLI_DOWNLOAD_DIR/awscli.zip" -d "$AWS_CLI_DOWNLOAD_DIR/awscli"

    # Run the installer
    sudo_askpass "$AWS_CLI_DOWNLOAD_DIR/awscli/aws/install" -i /usr/local/aws-cli -b /usr/local/bin

    # Cleanup
    rm -rf $AWS_CLI_DOWNLOAD_DIR

fi
