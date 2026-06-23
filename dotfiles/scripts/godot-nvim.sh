#!/bin/bash

# if [ -e /tmp/godot.nvim ]; then
#   exec /bin/nvim "$@"
# else
#   exec /bin/kitty -T "godot_nvim" -e nvim "$@"
# fi


# requirements: kitty, neovim-remote

SOCKET=/tmp/godot-nvim.sock

if [ -S "$SOCKET" ]; then
    exec nvr \
        --servername "$SOCKET" \
        --remote-tab-silent "$2"
else
    exec kitty \
        -T godot_nvim \
        -e nvim \
        --listen "$SOCKET" \
        "$2"
fi
