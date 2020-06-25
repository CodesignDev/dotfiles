#!/usr/bin/env bash

# Check if asdf is installed
if command_exists asdf; then

    # Are the plugins installed?
    if [[ -d "$ASDF_DATA_DIR/plugins/elixir" ]] && [[ -d "$ASDF_DATA_DIR/plugins/erlang" ]]; then

        # Get the latest version of elixir available and the latest compatible otp release
        ELIXIR_LATEST_VERSION=$(asdf list all elixir | grep -v - | grep -v master | tail -n 1)
        ELIXIR_LATEST_FULL_VERSION=$(asdf list all elixir | grep -v 'a\|b\|rc' | grep - | grep "^$ELIXIR_LATEST_VERSION" | tail -n 1)
        ELIXIR_LATEST_OTP_VERSION=$(echo $ELIXIR_LATEST_FULL_VERSION | grep -E -o "([0-9]+)$")

        # Get the latest compatible erlang version
        ERLANG_LATEST_VERSION=$(asdf list all erlang | grep -v - | grep "^$ELIXIR_LATEST_OTP_VERSION" | tail -n 1)

        # Install the requested elixir version
        asdf list elixir | sed 's/^  //' | grep $QUIET_FLAG_GREP $ELIXIR_LATEST_FULL_VERSION || {
            line "Installing latest elixir ($ELIXIR_LATEST_VERSION) via asdf..."
            asdf install elixir $ELIXIR_LATEST_FULL_VERSION
        }

        # Install the accompanying erlang version
        asdf list erlang | sed 's/^  //' | grep $QUIET_FLAG_GREP $ERLANG_LATEST_VERSION || {
            line "Installing latest erlang ($ERLANG_LATEST_VERSION) via asdf..."
            asdf install erlang $ERLANG_LATEST_VERSION
        }

        # Set these versions as the global defaults
        asdf global elixir $ELIXIR_LATEST_FULL_VERSION
        asdf global erlang $ERLANG_LATEST_VERSION
    fi
fi
