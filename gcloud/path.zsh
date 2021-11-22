# Bail if brew not installed
command -v brew 1>/dev/null 2>&1; || return 0

# Name of the gcloud cask
CASK_CLOUD_SDK_NAME="google-cloud-sdk"

# Brew's cask install directory
CASK_DIR="$(brew --caskroom)"

# Bail if the google-cloud-sdk package isn't installed
[[ -d "$CASK_DIR/$CASK_CLOUD_SDK_NAME" ]] || return 0

# Get the installed version from homebrew
CASK_CLOUD_SDK_VERSION="$(brew list --cask --versions $CASK_CLOUD_SDK_NAME | tr ' ' '\n' | tail -1)"

# Source the path script
source "$CASK_DIR/$CASK_CLOUD_SDK_NAME/$CASK_CLOUD_SDK_VERSION/path.zsh.inc"
