#!/bin/bash

Input=$1

if [ "$Input" == "" ]; then
  swayimg -g ~/Pictures/wallpaper/
fi

if [ "$Input" == "-b" ]; then
  swayimg -g ~/Pictures/wallpaper/21:9/
fi

if [ "$Input" != "" ] && [ "$Input" != "-b" ]; then
  echo "Usage:"
  echo "'wallpaper.sh': Open origin wallpapers"
  echo "'wallpaper.sh -b': Open 21:9 wallpapers"
fi
