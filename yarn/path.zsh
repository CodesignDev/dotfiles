export YARN_DIR="$HOME/.yarn"

if $(command_exists yarn); then
    export PATH="$(yarn global bin):$PATH"
else
    [[ -d "$YARN_DIR" ]] && export PATH="$YARN_DIR/bin:$PATH"
fi

