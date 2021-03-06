#!/usr/bin/env bash

# Current directory
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default pyenv directory
export PYENV_DIR="$HOME/.pyenv"

# Check if pyenv is not installed
if ! command_exists pyenv; then

    # Attempt to install pyenv via brew
    if ! packages restrict brew | packages install pyenv; then

        # Install failed. Install manually instead
        line "Installing pyenv..."

        # If the directory already exists, remove it, it could be an incomplete install
        [[ -d "$PYENV_DIR" ]] && rm -rf "$PYENV_DIR"

        # Clone the pyenv repo
        git clone https://github.com/pyenv/pyenv.git "$PYENV_DIR"

        # Build dynamic bash extension
        line "Building dynamic bash extension for pyenv..."
        sh -c "cd \"$PYENV_DIR\" && src/configure && make -C src" || {
            warning "Dyanmic bash extension for pyenv failed to build correctly."
        }

        # Include pyenv into the build shell
        PATH="$PYENV_DIR/bin:$PATH"
        eval "$(pyenv init -)"
    fi

else

    # pyenv is installed so set the PYENV_DIR to its root
    export PYENV_DIR=$(pyenv root)
fi

# Install some pyenv plugins
if command_exists pyenv; then

    # Create plugins directory (this should already exist but double check)
    mkdir -p "$(pyenv root)/plugins"

    # Attempt to install the virtualenv and which-ext plugins via brew, falling back to git clone if it fails
    packages restrict brew | packages install pyenv-virtualenv ||
        git clone https://github.com/pyenv/pyenv-virtualenv.git "$(pyenv root)/plugins/pyenv-virtualenv"
    packages restrict brew | packages install pyenv-which-ext ||
        git clone https://github.com/pyenv/pyenv-which-ext.git "$(pyenv root)/plugins/pyenv-which-ext"

   # Install default-packages, doctor, and update plugins
    git clone https://github.com/jawshooah/pyenv-default-packages.git "$(pyenv root)/plugins/pyenv-default-packages"
    git clone https://github.com/pyenv/pyenv-doctor.git "$(pyenv root)/plugins/pyenv-doctor"
    git clone https://github.com/pyenv/pyenv-update.git "$(pyenv root)/plugins/pyenv-update"
fi

# Install some prerequisites needed to build ruby
if command_exists pyenv; then

    line "Installing some pre-requisites for python..."
    packages restrict apt | packages install make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
    packages restrict brew | packages install openssl readline sqlite3 xz zlib

fi
