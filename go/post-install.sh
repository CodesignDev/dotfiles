#!/usr/bin/env bash

GO_SRC_PATH=${GOPATH:-"$PROJECTS_DIR/go"}

# Check if go is callable
if command_exists go; then

    # Create the go user paths
    [[ -d $GO_SRC_PATH ]] && mkdir -p $GO_SRC_PATH
    mkdir -p $GO_SRC_PATH/{bin,pkg,src}

    # Set up the gopath env variable
    export GOPATH=$GO_SRC_PATH

    # Install some dependencies
    line "Installing Go dependency manager..."
    curl -fsSL "https://raw.githubusercontent.com/golang/dep/master/install.sh" | sh

else

    # Throw a warning
    warning "Go has been installed but isn't currently available."
fi
