#!/usr/bin/env bash

# Is antibody installed
if ! command_exists gcloud; then

    # Print a message to the console
    line "Installing gcloud..."

    # Add the relevant repositories
    packages restrict apt | packages add_repository "google-cloud-sdk" "https://packages.cloud.google.com/apt" "cloud-sdk" "main" "https://packages.cloud.google.com/apt/doc/apt-key.gpg"

    # Install the cloud-sdk package relevant for each platform
    packages install google-cloud-sdk

fi
