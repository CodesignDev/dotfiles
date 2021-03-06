#!/usr/bin/env bash

# Current directory
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default rbenv directory
export RBENV_DIR="$HOME/.rbenv"

# Check if rbenv is not installed
if ! command_exists rbenv; then

    # Attempt to install pyenv via brew
    if ! packages restrict brew | packages install rbenv; then

        # Install failed. Install manually instead
        line "Installing rbenv..."

        # If the directory already exists, remove it, it could be an incomplete install
        [[ -d "$RBENV_DIR" ]] && rm -rf "$RBENV_DIR"

        # Clone the rbenv repo
        git clone https://github.com/rbenv/rbenv.git "$RBENV_DIR"

        # Build dynamic bash extension
        line "Building dynamic bash extension for rbenv..."
        sh -c "cd \"$RBENV_DIR\" && src/configure && make -C src" || {
            warning "Dyanmic bash extension for rbenv failed to build correctly."
        }

        # Include rbenv into the build shell
        PATH="$RBENV_DIR/bin:$PATH"
        eval "$(rbenv init -)"

        # Install ruby-build
        line "Installing ruby-build..."
        mkdir -p "$RBENV_DIR/plugins"
        git clone https://github.com/rbenv/ruby-build.git "$RBENV_DIR/plugins/ruby-build"
    fi

else

    # rbenv is installed so set the RBENV_DIR to its root
    export RBENV_DIR=$(rbenv root)
fi

# Install some rbenv plugins
if command_exists rbenv; then

    # Create plugins directory (this should already exist but double check)
    mkdir -p "$(rbenv root)/plugins"

    # Attempt to install the default-gems plugin via brew, falling back to git clone if it fails
    packages restrict brew | packages install rbenv-default-gems ||
        git clone https://github.com/rbenv/rbenv-default-gems.git "$(rbenv root)/plugins/rbenv-default-gems"

    # Install rbenv-each plugin
    git clone https://github.com/rbenv/rbenv-each.git "$(rbenv root)/plugins/rbenv-each"
fi

# Install some prerequisites needed to build ruby
if command_exists rbenv; then

    line "Installing some pre-requisites for ruby..."
    packages restrict apt | packages install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev
    packages restrict brew | packages install openssl readline

fi
