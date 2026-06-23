#!/bin/bash

# require wofi, mpv

# bv=$(wofi --dmenu --prompt "Bv")
bv=$(wl-paste)
echo $bv

if [[ "$bv" == "BV"* ]]; then
  notify-send "BV" "Opening $bv"
  mpv --quiet --no-terminal --title="mpv-bilibili" https://www.bilibili.com/video/$bv
elif [[ "$bv" == "https://www.bilibili.com/video/BV"* ]]; then
  notify-send "BV" "Opening $bv"
  mpv --quiet --no-terminal --title="mpv-bilibili" $bv
else
  notify-send "BV" "Not a BV or Url"
fi
