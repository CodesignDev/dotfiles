#!/usr/bin/env bash

# Current directory
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default pyenv directory
export PYENV_DIR="$HOME/.pyenv"

# Check if pyenv is not installed
if ! $(command_exists pyenv); then

    # If homebrew is installed, install pyenv via brew
    if $(command_exists brew); then

        # Install via brew
        brew_install pyenv

    else

        # Brew isn't available. Install manually
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
if $(command_exists pyenv); then

    # Create plugins directory (this should already exist but double check)
    mkdir -p "$(pyenv root)/plugins"

    # Install plugins via brew if available
    if $(command_exists brew); then

        # Install virtualenv and which-ext plugins
        brew_install pyenv-virtualenv
        brew_install pyenv-which-ext

    else

        # Install virtualenv and which-ext plugins via git
        git clone https://github.com/pyenv/pyenv-virtualenv.git "$(pyenv root)/plugins/pyenv-virtualenv"
        git clone https://github.com/pyenv/pyenv-which-ext.git "$(pyenv root)/plugins/pyenv-which-ext"
    fi

    # Install doctor and update plugins
    git clone https://github.com/pyenv/pyenv-doctor.git "$(pyenv root)/plugins/pyenv-doctor"
    git clone https://github.com/pyenv/pyenv-update.git "$(pyenv root)/plugins/pyenv-update"
fi

# Install latest ruby version
if $(command_exists pyenv); then

    # Get the latest python 2 and 3 versions currently availble
    PYTHON_3_LATEST_VERSION=$(pyenv install --list | sed 's/^  //' | grep -v - | grep -v 'dev\|a\|b' | grep '^3' | tail -1)
    PYTHON_2_LATEST_VERSION=$(pyenv install --list | sed 's/^  //' | grep -v - | grep -v 'dev\|a\|b' | grep '^2' | tail -1)

    # Install the latest v3 version if it isn't already installed
    pyenv versions --bare | grep $QUIET_FLAG_GREP $PYTHON_3_LATEST_VERSION || {
        line "Installing latest v3 python ($PYTHON_3_LATEST_VERSION) via pyenv..."
        pyenv install $PYTHON_3_LATEST_VERSION
    }

    # Install the latest v2 version if it isn't already installed
    pyenv versions --bare | grep $QUIET_FLAG_GREP $PYTHON_2_LATEST_VERSION || {
        line "Installing latest v2 python ($PYTHON_2_LATEST_VERSION) via pyenv..."
        pyenv install $PYTHON_2_LATEST_VERSION
    }
fi
