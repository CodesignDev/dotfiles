#!/usr/bin/env bash

# This is only for Linux
is_linux || return 0

# Update apt
packages update

# Install some core dependencies
line "Installing some prerequisite software for Linux..."
packages restrict !brew | packages install build-essential curl file git jq unzip
