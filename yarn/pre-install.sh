#!/usr/bin/env bash

# Currently linux only
is_linux || return 0

# Remove cmdtest if it is installed
packages restrict apt | packages remove cmdtest
