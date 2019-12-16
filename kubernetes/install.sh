#!/usr/bin/env bash

# Install kubectl
if ! $(command_exists kubectl); then

    # Add repo to apt if required
    apt_add_repo "https://apt.kubernetes.io" "kubernetes-xenial main" "https://packages.cloud.google.com/apt/doc/apt-key.gpg" "kubernetes"

    # Install the kubectl binary
    check_and_install kubectl
fi

# Install helm
if ! $(command_exists helm); then

    # Install helm via homebrew if available
    brew_install helm || {

        # Current step info
        line "Installing helm..."

        # Download helm's install script and run it
        curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    }
fi

# Install krew plugin manager for kubectl
if $(command_exists kubectl) && ! $(kubectl krew >/dev/null 2>&1); then

    # Get the latest version from the repo
    KREW_LATEST_VERSION=$(github_get_latest_release_version "kubernetes-sigs/krew")

    # Download and install the plugin manager
    line "Installing krew..."
    KREW_INSTALL_DIR=$(mktemp -d)
    curl -fsSL "https://github.com/kubernetes-sigs/krew/releases/$KREW_LATEST_VERSION/krew.tar.gz" > $KREW_INSTALL_DIR/krew.tar.gz
    curl -fsSL "https://github.com/kubernetes-sigs/krew/releases/$KREW_LATEST_VERSION/krew.yaml" > $KREW_INSTALL_DIR/krew.yaml
    tar zxvf $KREW_INSTALL_DIR/krew.tar.gz
    KREW_CMD=$KREW_INSTALL_DIR/krew-${OS}_amd64
    "$KREW_CMD" install --manifest=$KREW_INSTALL_DIR/krew.yaml --archive=$KREW_INSTALL_DIR/krew.tar.gz
    "$KREW_CMD" update

    # Cleanup
    rm -rf $KREW_INSTALL_DIR/* $KREW_INSTALL_DIR
fi
