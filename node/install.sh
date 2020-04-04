#!/usr/bin/env bash

# Current directory
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# nvm base directory
export NVM_DIR="$HOME/.nvm"

# Remove nvm if installed by homebrew, if applicable
if $(command_exists brew); then

    # Check if nvm has been installed via homebrew
    $(is_package_installed_brew nvm) && brew uninstall nvm --force

fi

# Is nvm already installed
if $(command_exists nvm); then

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

# Link default packages file to nvm
[[ -f "$NVM_DIR/default-packages" ]] && rm "$NVM_DIR/default-packages"
ln -sf $DIR/default_packages.txt $NVM_DIR/default-packages

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
