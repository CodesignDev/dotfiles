# dotnet directory
export DOTNET_DIR="$HOME/.dotnet"

# Add dotnet's directory to path
[[ -d "$DOTNET_DIR" ]] && export PATH="$DOTNET_DIR:$PATH"
