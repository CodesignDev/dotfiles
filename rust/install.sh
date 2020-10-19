#!/usr/bin/env bash

export CARGO_DIR="$HOME/.cargo"
export RUSTUP_DIR="$HOME/.rustup"

if ! command_exists rustup; then

    # Download the rustup-init binary
    line "Installing rustup..."

    # Download and run the rust-init.sh script
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --quiet -y --no-modify-path --default-toolchain none > /dev/null

    # Add the .cargo/bin directory to the path
    export PATH="$CARGO_DIR/bin:$PATH"
fi
