# Krew directory
export KREW_ROOT="${KREW_ROOT:-"$HOME/.krew"}"

# Add krew's bin directory to path if this is a manual install
[[ -d "$KREW_ROOT/bin" ]] && export PATH="$KREW_ROOT/bin:$PATH"
