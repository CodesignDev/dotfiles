# Set up pyenv in current shell
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"

    if $(pyenv commands | grep -q virtualenv-init); then
        eval "$(pyenv virtualenv-init -)"
    fi
fi
