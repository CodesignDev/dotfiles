#!/usr/bin/env bash

# Current directory
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Does kubectl exist
if command_exists kubectl; then

    # Install addons for kubectl (using krew)
    PLUGIN_FILE=$DIR/kube_plugins.txt
    if [[ -f $PLUGIN_FILE ]]; then

        # Install the plugins via krew
        line "Installing kubectl plugins..."
        kubectl krew install --no-update-index < $PLUGIN_FILE
    fi
fi
