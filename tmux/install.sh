#!/usr/bin/env bash

# Directory to hold tmux config
TMUX_CONF_DIF="$HOME/.tmux"

# Check if tmux is installed
if ! command_exists tmux; then

    line "Installing tmux..."

    # Install tmux from the relevant package manager
    packages install tmux
fi

# Install tmux plugins
if command_exists tmux; then

    line "Installing tmux plugins..."

    # Create the plugin directory
    mkdir -p "$TMUX_CONF_DIF/plugins"

    # Download the relevant plugins
    git clone https://github.com/tmux-plugins/tpm "$TMUX_CONF_DIF/plugins/tpm"

fi
