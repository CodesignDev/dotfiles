#!/usr/bin/env bash

# Check if asdf has been installed
if command_exists asdf; then

    # Install the elixir plugin
    if [[ ! -d "$ASDF_DATA_DIR/plugins/elixir" ]]; then
        line "Installing elixir plugin for asdf..."
        asdf plugin add elixir
    fi

    # Install the erlang plugin
    if [[ ! -d "$ASDF_DATA_DIR/plugins/erlang" ]]; then
        line "Installing erlang plugin for asdf..."
        asdf plugin add erlang
    fi

    # Install some prereqs for building erlang
    line "Installing some pre-requisites for erlang..."
    packages restrict apt | packages install autoconf m4 libncurses5-dev libpng-dev libssh-dev unixodbc-dev
    packages restrict brew | packages install autoconf wxmac

    is_wsl || packages restrict apt | packages install libwxgtk3.0-dev libwxgtk3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev
fi
