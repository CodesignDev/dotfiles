# pyenv directory
export PYENV_ROOT="$HOME/.pyenv"

# Add pyenv's bin directory to path if this is a manual install
[[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
