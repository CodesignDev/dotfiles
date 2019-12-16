#!/usr/bin/env bash

# Current directory
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install addons for kubectl (using krew)
PLUGIN_FILE=$DIR/kube_plugins.txt
if [[ ! -f $PLUGIN_FILE ]]; then

    # Install the plugins via krew
    kubectl krew install --no-update-index < $PLUGIN_FILE
fi

