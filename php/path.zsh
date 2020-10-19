# phpenv directory
export PHPENV_ROOT="$HOME/.phpenv"

# Add phpenv's bin directory to path if this is a manual install
[[ -d "$PHPENV_ROOT/bin" ]] && export PATH="$PHPENV_ROOT/bin:$PATH"
