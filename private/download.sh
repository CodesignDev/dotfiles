#!/usr/bin/env bash

# Get the path to the folder containing this file and the original folder
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Are we skipping section
[[ -z "$SKIP_PRIVATE_REPO_INSTALL" ]] || return 0

# Directories
REPOS_DIR=$DIR/repos
REPOS_BACKUP_DIR=$DIR/repo-backups

# Create the repo directories if needed
[[ ! -d "$REPOS_DIR" ]] && mkdir -p "$REPOS_DIR"
[[ ! -d "$REPOS_BACKUP_DIR" ]] && mkdir -p "$REPOS_BACKUP_DIR"

# Local variables
GITHUB_BASE=https://github.com

# Install some prerequisites. Required programs: [none]
# install_prerequisites

# Get the list of repos
REPO_LIST=$DIR/.repos

# If the repo list doesn't exist, then bail
if [[ ! -f "$REPO_LIST" ]]; then
    warning "No private repo list found. Skipping..."
    return 0
fi

# Change to the directory where these repos will be stored
cd $REPOS_DIR

# Loop through each line in the repo list file
while IFS= read -r line || [[ -n "$line" ]]; do

    # Some local variables
    URL_HAS_USER=0
    URL_HAS_SCHEME=0
    REPO_NAME=
    REPO_USER=
    REPO_SLUG=
    REPO_URL=

    # Skip lines that are comments
    [[ ${line:0:1} == "#" ]] && continue

    # Check if the line is in either USER/REPO format or just REPO
    [[ $(dirname "$line") != "." ]] && URL_HAS_USER=1

    # Does the line have a full URL (starts with http/https)
    [[ $line =~ ^https?:\/\/ ]] && URL_HAS_SCHEME=1

    # Is the current repo have a full remote URL
    if [[ $URL_HAS_SCHEME == 0 ]]; then

        # Extract various variables from the current repo
        REPO_NAME=$(basename $line)
        REPO_USER=$(dirname $line)

        # If no user is specifed then get the default GH user
        [[ $URL_HAS_USER == 0 ]] && REPO_USER=$GITHUB_USER

        # Craft the slug and url (assuming GH as no URL was specified)
        REPO_SLUG=$REPO_USER/$REPO_NAME
        REPO_URL=$GITHUB_BASE/$REPO_SLUG.git

    # This means that the current line is a full URL
    else

        # Get the URL
        REPO_URL=$line

        # Try and get the slug and name from the URL
        REPO_SLUG=$(basename $REPO_URL)
        REPO_SLUG=${REPO_SLUG%.git}
        REPO_NAME=$REPO_SLUG

    fi

    # Print a message to the terminal
    line "Cloning repo $REPO_SLUG..."

    # Check to see if the current repo is a valid and we have access to it
    if git ls-remote $REPO_URL -h &> /dev/null; then

        # Create the directory if it doesn't already exist
        [[ ! -d $REPO_NAME ]] && mkdir $REPO_NAME

        # Does a git repo already exist in this folder
        if [[ -d $REPO_NAME/.git ]]; then

            # Check if the origin remote matches our URL
            if [[ $(git --git-dir $REPOS_DIR/$REPO_NAME/.git remote get-url origin) == $REPO_URL ]]; then

                # Print an updating repo message
                line "Found an existing local copy of $REPO_SLUG, updating to latest version..."

                # Do a git pull on the repo to update it
                git --git-dir $REPOS_DIR/$REPO_NAME/.git pull origin

            else

                # The remote doesn't match, so move this repo into a backup folder and re-create it
                warning "Found an existing local copy of $REPO_SLUG, however the origin URL doesn't match."
                echo "Moving this repo to $REPOS_BACKUP_DIR/$REPO_NAME"
                mv $REPOS_DIR/$REPO_NAME $REPOS_BACKUP_DIR/$REPO_NAME

                # Re-create the folder
                mkdir $REPO_NAME

            fi
        fi

        # If the .git directory doesn't exist, set up the git repo and pull down the remote
        if [[ ! -d $REPO_NAME/.git ]]; then

            # Set the git diretory and the work tree
            export GIT_DIR=$REPOS_DIR/$REPO_NAME/.git
            export GIT_WORK_TREE=$REPOS_DIR/$REPO_NAME

            # Set up the git directory
            git init $QUIET_FLAG_GIT
            git config remote.origin.url "$REPO_URL"
            git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

            # Fetch and reset the work tree
            git fetch $QUIET_FLAG_GIT --force
            git reset $QUIET_FLAG_GIT --hard origin/master

            # Clear the git directory and work tree variables
            unset GIT_DIR GIT_WORK_TREE

        fi
    else

        # We don't have access to this repo so print a warning
        warning "Skipping repository '$REPO_SLUG' due to not being able to access it"

    fi

# End the loop and pass in our repo list file
done < $REPO_LIST

# Change directory back
cd -

# Unset variables that were used
unset URL_HAS_USER
unset URL_HAS_SCHEME
unset REPO_NAME
unset REPO_USER
unset REPO_SLUG
unset REPO_URL
