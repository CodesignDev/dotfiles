#!/usr/bin/env bash

# Get thepath to thefolder containing this file
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Include the debug library
source $DIR/debug.sh

# Set up debug
debug_init $@

# Get the OS
source $DIR/os.sh
detect_os

# Incldue our other libraries
source $DIR/colours.sh
source $DIR/terminal.sh
source $DIR/utils.sh
source $DIR/packages.sh
source $DIR/sudo.sh
source $DIR/topics.sh

# Initalize some things
is_interactive_shell
init_colours
