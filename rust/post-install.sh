#!/usr/bin/env bash

# Is rustup available
if command_exists rustup; then

    # Install the stable version of rust via rustup
    rustup toolchain install stable

else

    # Throw a warning
    warning "rustup has been installed but isn't currently available."
fi
