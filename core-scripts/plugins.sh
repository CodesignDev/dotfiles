#!/usr/bin/env bash

plugins_init() {
    local ROOT_DIR=${1:-$DOTFILES_DIR}
    local PLUGINS_DIR="plugins"

    # If the root directory is not valid then exit
    [[ -d $ROOT_DIR ]] || return 0

    # Try and create the directory if it doesn't exist
    mkdir -p $ROOT_DIR/$PLUGINS_DIR

    # Loop through each plugin directory
    for PLUGIN_DIR in $ROOT_DIR/$PLUGINS_DIR/*/; do

        # Remove the final slash from the directory path
        PLUGIN_DIR=${PLUGIN_DIR%/}

        # Stop processing if the directory isn't valid
        [[ ${PLUGIN_DIR: -1} == "*" ]] && continue

        # Get the name of the plugin dir
        local PLUGIN_NAME=$(basename $PLUGIN_DIR)

        # Get the name of the plugin file
        local PLUGIN_FILE=$(plugins_get_plugin_file $PLUGIN_DIR $PLUGIN_NAME)

        # Load the plugin
        [[ -f $PLUGIN_DIR/$PLUGIN_FILE ]] && DF_PLUGIN=true source $PLUGIN_DIR/$PLUGIN_FILE
    done

    # Fire the plugin init attempt after loading each of the plugins
    hook_run plugin_init
}

plugins_get_plugin_file() {
    local PLUGIN_DIR=$1
    local PLUGIN_NAME=$2

    # Local Variables
    local PLUGIN_NAME_OPTIONS=()
    local PLUGIN_FILE_PREFIXES=("dotfiles-plugin" "df-plugin" dotfiles df dfplugin plugin)
    local PLUGIN_FILE_SUFFIXES=(dfplugin plugin)

    # Add the passed name as the starting point
    PLUGIN_NAME_OPTIONS+=($PLUGIN_NAME)

    # Alternative versions of prefixes (using _ instead of -)
    for PREFIX in ${PLUGIN_FILE_PREFIXES[@]}; do
        [[ $PREFIX =~ .*"-".* ]] && PLUGIN_FILE_PREFIXES+=($(echo $PREFIX | sed -r 's/-/_/g'))
    done

    # Alternative versions of the passed name (creating both _ and - only versions)
    for NAME in ${PLUGIN_NAME_OPTIONS[@]}; do
        PLUGIN_NAME_OPTIONS+=($(echo $NAME | sed -r 's/-/_/g'))
        PLUGIN_NAME_OPTIONS+=($(echo $NAME | sed -r 's/_/-/g'))
    done

    # Loop through each name and attempt to remove one of the prefixes
    for NAME in ${PLUGIN_NAME_OPTIONS[@]}; do
        for PREFIX in ${PLUGIN_FILE_PREFIXES[@]}; do
            [[ "${NAME#${PREFIX}-}" == "$NAME" ]] || PLUGIN_NAME_OPTIONS+=(${NAME#${PREFIX}-})
            [[ "${NAME#${PREFIX}_}" == "$NAME" ]] || PLUGIN_NAME_OPTIONS+=(${NAME#${PREFIX}_})
        done
    done

    # Remove duplicates
    PLUGIN_NAME_OPTIONS=($(echo ${PLUGIN_NAME_OPTIONS[@]} | tr ' ' '\n' | sort -u | tr '\n' ' '))

    # Add suffix variants (name.dfplugin and name.plugin)
    for NAME in ${PLUGIN_NAME_OPTIONS[@]}; do
        for SUFFIX in ${PLUGIN_FILE_SUFFIXES[@]}; do
            PLUGIN_NAME_OPTIONS+=($NAME.$SUFFIX)
        done
    done

    # Loop through each current name and see if the file exists and return it
    for NAME in ${PLUGIN_NAME_OPTIONS[@]}; do
        plugin_check_and_get_plugin_file $PLUGIN_DIR/$NAME.sh && return 0
    done

    return 1
}

plugin_check_and_get_plugin_file() {
    PLUGIN_FILE=$1

    # Bail if the file doesn't exist
    [[ -f $PLUGIN_FILE ]] || return 1

    # Return just the file name
    echo $(basename $PLUGIN_FILE)
    return 0
}
