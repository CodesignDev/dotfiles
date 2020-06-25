# asdf default directory
export ASDF_DIR="$HOME/.asdf"
export ASDF_DATA_DIR="${ASDF_DATA_DIR:-$ASDF_DIR}"

# Get directory of  installed directory if applicable
if command -v brew 1>/dev/null 2>&1; then
    export ASDF_DIR="$(brew --prefix asdf)"
fi

# Load asdf
[[ -s "$ASDF_DIR/asdf.sh" ]] && \. "$ASDF_DIR/asdf.sh"
