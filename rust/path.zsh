# rustup and cargo directory
export CARGO_DIR="$HOME/.cargo"
export RUSTUP_DIR="$HOME/.rustup"

# Add cargo's bin directory to path
[[ -d "$CARGO_DIR/bin" ]] && export PATH="$CARGO_DIR/bin:$PATH"
