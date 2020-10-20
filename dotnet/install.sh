#!/usr/bin/env bash

# Default directory for dotnet
export DOTNET_DIR="$HOME/.dotnet"

# Is dotnet already installed
if ! command_exists dotnet; then

    # Download the dotnet sdk
    line "Installing dotnet SDK..."

    # Download and run the dotnet-install.sh script
    curl -fsSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel "LTS" --version "latest" --install-dir "$DOTNET_DIR" > /dev/null

    # Add the dotnet directory to the path
    export PATH="$DOTNET_DIR:$PATH"
fi
