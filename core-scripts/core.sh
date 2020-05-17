#!/usr/bin/env bash

# Get the path to the folder containing this file
CORE_SCRIPTS_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check for already initialized core
CORE_INITIALIZED=${CORE_INITIALIZED:-0}
[[ "$CORE_INITIALIZED" == "1" ]] && return 0
CORE_INITIALIZED=1

# Include the debug library
source $CORE_SCRIPTS_DIR/debug.sh

# Set up debug
debug_init $@

# Include terminal related libraries
source $CORE_SCRIPTS_DIR/shell.sh
source $CORE_SCRIPTS_DIR/colours.sh
source $CORE_SCRIPTS_DIR/terminal.sh

# Initialize the terminal functions
is_interactive_shell
init_colours

# Include env related functions
source $CORE_SCRIPTS_DIR/env.sh

# Check for root user
env_check_root && {
    error "Don't run this as root!"
    exit 1
}

# Include the hooks system
source $CORE_SCRIPTS_DIR/hooks.sh

# Initialize hooks
hooks_init
trap "hook_run cleanup" EXIT

# Get the OS and Arch
source $CORE_SCRIPTS_DIR/os.sh
source $CORE_SCRIPTS_DIR/arch.sh
detect_os
detect_arch

# Incldue our other core libraries
source $CORE_SCRIPTS_DIR/commands.sh
source $CORE_SCRIPTS_DIR/sudo.sh
source $CORE_SCRIPTS_DIR/topics.sh


# Initialize the plugins system
source $CORE_SCRIPTS_DIR/plugins.sh
plugins_init

# Initialize the relevant package managers
source $CORE_SCRIPTS_DIR/package-manager.sh
source $CORE_SCRIPTS_DIR/packages-core.sh
init_package_manager_actions

# Miscellaneous utilities
source $CORE_SCRIPTS_DIR/github.sh
source $CORE_SCRIPTS_DIR/utils.sh

# Run init hook
hook_run init
