#!/usr/bin/env bash

# Current directory
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If nvm is installed and is available, install the necessary node versions
if $(command_exists nvm); then

    # Get the node versions for latest and lts
    NODE_LATEST_VERSION=$(nvm_remote_version | awk '{print $1}')
    NODE_LTS_VERSION=$(NVM_LTS=* nvm_remote_version | awk '{print $1}')

    # If latest/lts node isn't installed, then install it
    [[ -d "$NVM_DIR/versions/$NODE_LATEST_VERSION/" ]] || {
        line "Installing latest node ($NODE_LATEST_VERSION) via nvm..."
        nvm install node --latest-npm
    }
    [[ -d "$NVM_DIR/versions/$NODE_LTS_VERSION/" ]] || {
        line "Installing latest lts node ($NODE_LTS_VERSION) via nvm..."
        nvm install --lts --latest-npm
    }

    # Alias the latest node to default
    nvm alias default node
fi
