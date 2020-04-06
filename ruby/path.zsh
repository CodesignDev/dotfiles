# rbenv directory
export RBENV_ROOT="$HOME/.rbenv"

# Add rbenv's bin directory to path if this is a manual install
[[ -d "$RBENV_ROOT/bin" ]] && export PATH="$RBENV_ROOT/bin:$PATH"
