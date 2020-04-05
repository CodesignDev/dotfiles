# rbenv directory
export RBENV_DIR="$HOME/.rbenv"

# Add rbenv's bin directory to path if this is a manual install
[[ -d "$RBENV_DIR/bin" ]] && export PATH="$RBENV_DIR/bin:$PATH"

# Set up rbenv in current shell
eval "$(rbenv init -)"
