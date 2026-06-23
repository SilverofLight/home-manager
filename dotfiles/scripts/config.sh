#!/bin/bash

# author: Silver Lee
# date: 2024/12/6
# description: use tmux open my mydots dir
# requirements: tmux, yazi

if [ -n "$TMUX" ]; then
  tmux new-window -n "config"
  tmux send-keys -t config "cd ~/mydots/" C-m
  tmux send-keys -t config "yazi" C-m
else

  if tmux has-session -t config 2>/dev/null; then
    tmux attach -t config
  else 
    tmux new-session -d -s config
  
    tmux send-keys -t config "cd ~/mydots/" C-m
    tmux send-keys -t config "yazi" C-m
  
    tmux attach-session -t config
  fi

fi
