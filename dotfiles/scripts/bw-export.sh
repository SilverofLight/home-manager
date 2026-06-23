#!/bin/bash

# require: bitwarden

command -v bw >/dev/null 2>&1 || {
    echo "错误：未找到命令 bw" >&2
    exit 1
}

bw sync

bw export --output $HOME/Documents/keys/passwords.csv
