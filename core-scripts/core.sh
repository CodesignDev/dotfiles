#!/usr/bin/env bash

# Get the path to the folder containing this file
CORE_SCRIPTS_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Include the debug library
source $CORE_SCRIPTS_DIR/debug.sh

# Set up debug
debug_init $@

# Get the OS and Arch
source $CORE_SCRIPTS_DIR/os.sh
source $CORE_SCRIPTS_DIR/arch.sh
detect_os
detect_arch

# Incldue our other core libraries
source $CORE_SCRIPTS_DIR/commands.sh
source $CORE_SCRIPTS_DIR/shell.sh
source $CORE_SCRIPTS_DIR/sudo.sh
source $CORE_SCRIPTS_DIR/topics.sh

# Initialize the relevant package managers
source $CORE_SCRIPTS_DIR/package-manager.sh
source $CORE_SCRIPTS_DIR/packages-core.sh
init_package_manager_actions

# Initialize our termainl related libraries
source $CORE_SCRIPTS_DIR/colours.sh
source $CORE_SCRIPTS_DIR/terminal.sh

# Miscellaneous utilities
source $CORE_SCRIPTS_DIR/utils.sh

# Initalize some things
is_interactive_shell
init_colours
