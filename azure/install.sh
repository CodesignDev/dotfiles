#!/usr/bin/env bash

# Is antibody installed
if ! command_exists az; then

    # Print a message to the console
    line "Installing azure-cli..."

    # Add the relevant repositories
    packages restrict apt | packages add_repository "azure-cli" "https://packages.microsoft.com/repos/azure-cli/" $OS_DISTRIBUTION "main" "https://packages.microsoft.com/keys/microsoft.asc"

    # Install the azure cli package relevant for each platform
    packages install azure-cli

fi
