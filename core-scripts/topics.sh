#!/usr/bin/env bash

# Runs the scripts inside each topic folder
run_topic_scripts() {

    # Variables
    local ROOT_DIR=$1
    local FILES=(${@:2})
    local DIR
    local SCRIPT_FILES

    # Bail if the root directory isn't valid
    [[ ! -d $ROOT_DIR ]] && return 0

    # Loop through each file passed
    for FILE in ${FILES[@]}; do

        # Call before start hook
        hook_run before_topic $ROOT_DIR $FILE

        # Create a new array with the current file and the prefixed variant
        SCRIPT_FILES=(_$FILE $FILE)

        # Loop through each directory in the specified root directory
        for DIR in $ROOT_DIR/*/; do

            # Remove the final slash from the directory path
            DIR=${DIR%/}

            # Stop processing if the directory isn't valid
            [[ ${DIR: -1} == "*" ]] && continue

            # Get the current topic folder
            TOPIC=$(get_topic_name $DIR)

            # Skip if this directory is a protected one
            is_protected_topic $TOPIC || continue

            # Loop through each of the script files (prefixed and normal)
            for SCRIPT_FILE in ${SCRIPT_FILES[@]}; do

                # Check if this topic should be skipped (but only for the non-prefixed script)
                if ! is_prefixed_script $SCRIPT_FILE; then
                    should_skip_topic $TOPIC || continue
                fi

                # If the file exists, run it
                [[ -f $DIR/$SCRIPT_FILE ]] || continue

                # Arguments that are passed to the hooks
                HOOK_ARGS=(
                    $ROOT_DIR
                    $FILE
                    $TOPIC
                    $DIR
                    $SCRIPT_FILE
                )

                # Run the before topic exec hook
                hook_run before_topic_exec ${HOOK_ARGS[*]}

                # Run the script and the topic_exec hook
                source $DIR/$SCRIPT_FILE
                hook_run topic_exec ${HOOK_ARGS[*]}

                # Run the after topic exec hook
                hook_run after_topic_exec ${HOOK_ARGS[*]}

            done

        done

        # Call the after topic hook
        hook_run after_topic $ROOT_DIR $FILE

        # Run this file through the private repos as well
        run_private_topic_scripts $ROOT_DIR $FILE

    done

    return 0
}

# Runs the specified script in the topic folders in each private dotfiles repo
run_private_topic_scripts() {

    # Variables
    local ROOT_DIR=$1
    local FILE=$2
    local PRIVATE_DIR
    local PRIVATE_REPOS_PATH="private/repos"

    # Bail if the private folder doesn't exist
    [[ ! -d $ROOT_DIR/$PRIVATE_REPOS_PATH/ ]] && return 0

    # Loop through each folder inside this private directory
    for PRIVATE_DIR in $ROOT_DIR/$PRIVATE_REPOS_PATH/; do

        # Remove the final slash from the path
        PRIVATE_DIR=${PRIVATE_DIR%/}

        # Run the topic scripts inside this directory
        run_topic_scripts $PRIVATE_DIR $FILE

    done

    return 0
}

# Get the topic folder from a path
get_topic_name() {
    local TOPIC_PATH=$1

    # If the path passed is a file then strip this off
    if [[ -f $TOPIC_PATH ]]; then

        # Strip the file
        TOPIC_PATH=$(dirname $TOPIC_PATH)

    fi

    # Basename does exactly what we need here
    echo $(basename $TOPIC_PATH)
}

# Check if the current topic is a protected topic
is_protected_topic() {
    local TOPIC=$1

    # Check for the core-scripts and script folders
    [[ $TOPIC == "bin" ]] && return 1
    [[ $TOPIC == "core-scripts" ]] && return 1
    [[ $TOPIC == "plugins" ]] && return 1
    [[ $TOPIC == "script" ]] && return 1

    # Check for the private repos folder
    [[ $TOPIC == "private" ]] && return 1

    # Not a protected topic
    return 0
}

is_prefixed_script() {
    local SCRIPT=$1

    # Test if this is a prefixed script (current prefix is _)
    [[ ${SCRIPT:0:1} == "_" ]]
    return
}

# Should this topic be skipped
should_skip_topic() {
    local TOPIC=$1
    local VARIABLE

    # Convert dashes to underscores
    TOPIC=${TOPIC//-/_}

    # Convert the topic name into uppercase
    TOPIC=$(echo $TOPIC | tr [:lower:] [:upper:])

    # Get the name of the skip topic variable
    VARIABLE=SKIP_${TOPIC}_INSTALL

    # Test if this variable exists and then return the result of this
    [[ -z ${!VARIABLE} ]] && return
}
