#!/usr/bin/env bash

# Krew directory
KREW_DIR="$HOME/.krew"

# Install kubectl
if ! command_exists kubectl; then

    # Add repo to apt if required
    packages restrict apt | packages add_repository "kubernetes" "https://apt.kubernetes.io" "kubernetes-xenial" "main" "https://packages.cloud.google.com/apt/doc/apt-key.gpg"

    # Install the kubectl binary
    packages install kubectl

    # Remove the krew directory if it exists, as we've just installed kubectl
    [[ -d $KREW_DIR ]] && rm -rf $KREW_DIR

fi

# Install helm
if ! command_exists helm; then

    # Install helm via homebrew if available
    if ! packages restrict brew | packages install helm; then

        # Current step info
        line "Installing helm..."

        # Download helm's install script and run it
        curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    fi
fi

# Install krew plugin manager for kubectl, only if kubectl is installed
if command_exists kubectl && [[ ! -d $KREW_DIR ]]; then

    # Get the latest version from the repo
    KREW_LATEST_VERSION=$(github_get_latest_release_version "kubernetes-sigs/krew")

    # Download and install the plugin manager
    line "Installing krew..."
    KREW_DOWNLOAD_DIR=$(mktemp -dt kubectl-krew.XXXXXXXX)
    curl -fsSL "https://github.com/kubernetes-sigs/krew/releases/download/$KREW_LATEST_VERSION/krew.tar.gz" > $KREW_DOWNLOAD_DIR/krew.tar.gz

    # Extract the archive
    tar zxvf $KREW_DOWNLOAD_DIR/krew.tar.gz -C $KREW_DOWNLOAD_DIR

    # Try and get the relevant file for this OS / arch
    KREW_CMD=$KREW_DOWNLOAD_DIR/krew-${OS}_${OS_ARCH}

    # If that isn't a valid combination, fallback to the 64bit version
    [[ -f $KREW_CMD ]] || KREW_CMD=$KREW_DOWNLOAD_DIR/krew-${OS}_amd64

    # Install krew and update its plugin index
    "$KREW_CMD" install krew
    "$KREW_CMD" update

    # Cleanup
    rm -rf $KREW_DOWNLOAD_DIR
fi
