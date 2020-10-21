#!/usr/bin/env bash

# Flag to say whether java is currently installed. macOS has a different check compared to linux
JAVA_INSTALLED=0

# Check linux
is_linux && ! command_exists java && JAVA_INSTALLED=1

# Check macOS, we need to check if anything is inside the root /Library directory
is_macos && [[ ! "$(ls -A /Library/Java/JavaVirtualMachines/)" ]] && JAVA_INSTALLED=1

# If java is not installed, install it
if [[ "$JAVA_INSTALLED" == "0" ]]; then

    line "Instaling java..."

    # Install the package from the relevant package managers
    packages restrict apt | packages install default-jdk
    packages restrict brew | packages install openjdk

    # For macOS, link the installed jdk so that the macOS java wrapper can find it
    if is_macos; then

        line "Linking jdk..."

        # Link the installed jdk folder to the system Java folder
        sudo_askpass ln -sfn "$(brew --prefix)/opt/openjdk/libexec/openjdk.jdk" "/Library/Java/JavaVirtualMachines/openjdk.jdk"
    fi
fi
