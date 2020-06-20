export YARN_DIR="$HOME/.yarn"

if command -v yarn 1>/dev/null 2>&1; then
    export PATH="$(yarn global bin):$PATH"
else
    [[ -d "$YARN_DIR" ]] && export PATH="$YARN_DIR/bin:$PATH"
fi

