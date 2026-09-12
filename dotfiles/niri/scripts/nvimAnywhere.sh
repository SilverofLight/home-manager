#!/bin/bash

# author: Silver Lee
# date: 2025/1/30
# description: use nvim to edit a temporary file and copy the content to clipboard
# requirements: kitty, nvim, wl-copy || xclip || pbcopy

temp_file=$(mktemp /tmp/nvimAnywhere.XXXXXX.md)

# st -T nvimAnywhere fish -c "nvim $temp_file"
kitty -T nvimAnywhere fish -c "nvim $temp_file"

# Read the content of the temp file
content=$(cat $temp_file)

# Check if content starts with "miao "
if [[ "$content" == miao* ]]; then
    # Extract the command after "miao "
    command_to_run="${content#miao }"

    # Update content to only contain the command (without "miao ")
    text="$command_to_run"
    notify-send "miao.py" "请稍等一下喵～主人不要着急，让本喵慢慢来哦～呼噜噜～很快就好的啦！"
    content=$(~/.scripts/miao.py $text)
    dunstctl close-all
    notify-send "miao.py" "嗯～已经转换好啦，主人满意吗？喵～呼噜噜～尾巴都开心地摇摇啦！\n\n下面是转换之后的结果喵～\n\n$content"
fi


if command -v wl-copy &> /dev/null; then
    echo "$content" | wl-copy
elif command -v xclip &> /dev/null; then
    echo "$content" | xclip -selection clipboard
elif command -v pbcopy &> /dev/null; then
    echo "$content" | pbcopy
else
    echo "未找到 wl-copy, xclip 或 pbcopy，无法复制到剪切板"
fi

rm "$temp_file"
