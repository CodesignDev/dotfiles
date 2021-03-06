#!/usr/bin/env bash

# Current directory
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# nvm base directory
export NVM_DIR="$HOME/.nvm"

# Remove nvm if installed by homebrew, if applicable
packages restrict brew | packages remove nvm

# Is nvm already installed
if command_exists nvm; then

    # NVM is installed, so attempt to create the nvm directory. If the directory already exists, this will just fail silently
    mkdir -p $NVM_DIR 2>/dev/null

else

    # NVM isn't installed, so if the folder already exists, delete it so the installer will download and install nvm
    [[ -d $NVM_DIR ]] && rm -rf $NVM_DIR

fi

# If the directory doesn't exist, download nvm
if [[ ! -d $NVM_DIR ]]; then

    # Install nvm
    line "Installing nvm..."
    git clone $QUIET_FLAG_GIT https://github.com/nvm-sh/nvm.git "$NVM_DIR"

    # Checkout the latest version
    NVM_TAG_LIST=$(git --git-dir=$NVM_DIR/.git --work-tree=$NVM_DIR rev-list --tags --max-count=1)
    NVM_VERSION=$(git --git-dir=$NVM_DIR/.git --work-tree=$NVM_DIR describe --abbrev=0 --tags --match "v[0-9]*" $NVM_TAG_LIST)
    git --git-dir=$NVM_DIR/.git --work-tree=$NVM_DIR checkout $QUIET_FLAG_GIT $NVM_VERSION

    # Load into the install shell
    . "$NVM_DIR/nvm.sh"
fi
