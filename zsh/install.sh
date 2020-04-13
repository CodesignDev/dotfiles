#!/usr/bin/env bash

# Is yarn not installed
if ! is_shell_installed zsh; then

    # Install the zsh shell
    install_package zsh
fi
