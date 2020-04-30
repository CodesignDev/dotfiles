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

        [[ -f $PLUGIN_DIR/$PLUGIN_FILE ]] && DF_PLUGIN=true source $PLUGIN_DIR/$PLUGIN_FILE
    done

    hook_run plugin_init
}

plugins_get_plugin_file() {
    local PLUGIN_DIR=$1
    local PLUGIN_NAME=$2

    local PLUGIN_NAME_PREFIX="dotfiles-plugin-"
    local POSSIBLE_PLUGIN_NAMES=()
    local PLUGIN_FILE_SUFFIXES=(dfplugin plugin)

    POSSIBLE_PLUGIN_NAMES+=($PLUGIN_NAME)
    POSSIBLE_PLUGIN_NAMES+=(${PLUGIN_NAME#"$PLUGIN_NAME_PREFIX"})

    for NAME in ${POSSIBLE_PLUGIN_NAMES[@]}; do
        POSSIBLE_PLUGIN_NAMES+=($(echo $NAME | sed -r 's/-/_/g'))
    done

    for NAME in ${POSSIBLE_PLUGIN_NAMES[@]}; do
        for SUFFIX in ${PLUGIN_FILE_SUFFIXES[@]}; do
            plugin_check_and_get_plugin_file $PLUGIN_DIR/$NAME.$SUFFIX.sh && return 0
        done
        plugin_check_and_get_plugin_file $PLUGIN_DIR/$NAME.sh && return 0
    done

    for NAME in ${PLUGIN_FILE_SUFFIXES[@]}; do
        plugin_check_and_get_plugin_file $PLUGIN_DIR/$NAME.sh && return 0
    done

    return 1
}

plugin_check_and_get_plugin_file() {
    PLUGIN_FILE=$1

    [[ -f $PLUGIN_FILE ]] || return 1

    echo $(basename $PLUGIN_FILE)
    return 0
}
