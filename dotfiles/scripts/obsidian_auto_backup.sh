#!/bin/bash

# 需要一个不需要密码的 ssh-key

cd ~/Study/Obsidian/
date=$(date +%Y-%m-%d-%H-%M-%S)

if [ -n "$(git status -s)" ]; then
  echo "Backuping..."
  git add .
  git commit -m "Obsidian Backup: $date"
  git push
fi
