#!/usr/bin/env bash

# asdf directory
ASDF_DIR="${ASDF_DIR:-$HOME/.asdf}"

# Is asdf already installed
if ! command_exists asdf; then

    # Attempt to install via brew if possible
    if packages restrict brew | packages install asdf; then

        # Get the path to the installed version from homebrew
        ASDF_DIR="$(brew --prefix asdf)"

    # Otherwise install manually via git
    else

        # Print progress message
        line "Removing previous installs of asdf..."

        # Remove the asdf directory if it already exists, it could be from a bad install
        [[ -d $ASDF_DIR ]] && rm -rf $ASDF_DIR

        # Installing message
        line "Installing asdf..."

        # Download and set up the asdf git repo
        git clone https://github.com/asdf-vm/asdf.git $ASDF_DIR

        # Get the latest tag
        ASDF_TAG_LIST=$(git --git-dir=$ASDF_DIR/.git --work-tree=$ASDF_DIR rev-list --tags --max-count=1)
        ASDF_VERSION=$(git --git-dir=$ASDF_DIR/.git --work-tree=$ASDF_DIR describe --abbrev=0 --tags --match "v[0-9]*" $ASDF_TAG_LIST)
        git --git-dir=$ASDF_DIR/.git --work-tree=$ASDF_DIR checkout $QUIET_FLAG_GIT $ASDF_VERSION
    fi

    # Load asdf into the install shell
    . "$ASDF_DIR/asdf.sh"
fi
