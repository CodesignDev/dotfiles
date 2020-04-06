# Go related env variables
export GOROOT="/usr/local/go"
export GOPATH="${GOPATH:-$PROJECTS_DIR/go}"

# Add the go root to the path if it exists
[[ -d $GOROOT ]] && export PATH="$GOROOT/bin:$PATH"

# Add the project bin directory to path
export PATH="$GOPATH/bin:$PATH"
