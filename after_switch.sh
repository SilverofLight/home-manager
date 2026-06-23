#!/bin/bash

if command -v bw &>/dev/null; then
    echo 'bw export notes api-keys > "$HOME/Documents/keys/api_keys.fish"'
    bw export notes api-keys > "$HOME/Documents/keys/api_keys.fish"
    echo "[OK] api keys exported"
else
    echo "\033[30;43m[WARNING]\033[0m bitwarden is not installed"
fi

echo "cp ./dotfiles/mouseless/mouseless.service /etc/systemd/system/"
cp ./dotfiles/mouseless/mouseless.service /etc/systemd/system/

echo "[OK] mouseless.service installed"

echo "systemctl enable --now mouseless.service"
systemctl enable --now mouseless.service

echo "[OK] mouseless.service enabled"
