#!/usr/bin/env bash

# Default phpenv directory
export PHPENV_DIR="$HOME/.phpenv"

# Check if phpenv is not installed
if ! command_exists phpenv; then

    # Install failed. Install manually instead
    line "Installing phpenv..."

    # If the directory already exists, remove it, it could be an incomplete install
    [[ -d "$PHPENV_DIR" ]] && rm -rf "$PHPENV_DIR"

    # Clone the phpenv repo
    git clone https://github.com/phpenv/phpenv.git "$PHPENV_DIR"

    # Include phpenv into the build shell
    PATH="$PHPENV_DIR/bin:$PATH"
    eval "$(phpenv init -)"

    # Install php-build
    line "Installing php-build..."
    mkdir -p "$PHPENV_DIR/plugins"
    git clone https://github.com/php-build/php-build.git "$PHPENV_DIR/plugins/php-build"

else

    # phpenv is installed so set the PHPENV_DIR to its root
    export PHPENV_DIR=$(phpenv root)
fi

# Install some phpenv plugins
if command_exists phpenv; then

    line "Installing phpenv plugins..."

    # Create plugins directory (this should already exist but double check)
    mkdir -p "$(phpenv root)/plugins"

    # Install the aliases and composer plugin
    git clone https://github.com/madumlao/phpenv-aliases.git "$PHPENV_DIR/plugins/phpenv-aliases"
    git clone https://github.com/sergeyklay/phpenv-config-add.git "$PHPENV_DIR/plugins/phpenv-config-add"
    git clone https://github.com/ngyuki/phpenv-composer.git "$PHPENV_DIR/plugins/phpenv-composer"

fi

# Install some prerequisites needed to build php
if command_exists phpenv; then

    line "Installing some pre-requisites for php..."

    # Apt packages
    APT_NO_INSTALL_RECOMMENDED=1 packages restrict apt | packages install autoconf2.13 autoconf2.64 autoconf bash bison build-essential ca-certificates curl \
        findutils git libbz2-dev libcurl4-gnutls-dev libicu-dev libjpeg-dev libmcrypt-dev libonig-dev libpng-dev libreadline-dev libsqlite3-dev libssl-dev \
        libtidy-dev libxml2-dev libxslt1-dev libzip-dev pkg-config re2c zlib1g-dev

    # Brew packages
    packages restrict brew | packages install autoconf autoconf@2.13 bzip2 icu4c libedit libiconv libjpeg libmcrypt libxml2 libzip oniguruma openssl \
        pkg-config python re2c tidy-html5 zlib
fi
