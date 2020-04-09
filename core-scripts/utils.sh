#!/usr/bin/env bash

github_get_latest_release_version() {
    REPO=$1
    curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | jq -j '.tag_name'
}
