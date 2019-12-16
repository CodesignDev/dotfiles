#!/usr/bin/env bash

# Get the path to the folder containing this file
CORE_SCRIPTS_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Include the debug library
source $CORE_SCRIPTS_DIR/debug.sh

# Set up debug
debug_init $@

# Get the OS
source $CORE_SCRIPTS_DIR/os.sh
detect_os

# Get the Arch
source $CORE_SCRIPTS_DIR/arch.sh
detect_arch

# Incldue our other libraries
source $CORE_SCRIPTS_DIR/colours.sh
source $CORE_SCRIPTS_DIR/terminal.sh
source $CORE_SCRIPTS_DIR/utils.sh
source $CORE_SCRIPTS_DIR/packages.sh
source $CORE_SCRIPTS_DIR/sudo.sh
source $CORE_SCRIPTS_DIR/topics.sh

# Initalize some things
is_interactive_shell
init_colours
