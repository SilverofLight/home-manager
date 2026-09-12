#!/bin/bash

# author: Silver Lee
# date: 2025/1/5
# description: move a window to specific workspace
# requirements: wofi, hyprland

# workspaces=$(hyprctl workspaces | grep "workspace ID" | awk -F'[()]' '{print $2}')

workspaces=$(hyprctl workspaces | grep "workspace ID" | awk '{print $2,$3,$4,$5,$6,$7}')

chosen_workspace=$(echo -e "$workspaces\nCreateNew" | wofi --dmenu --prompt "Move to workspace")

# echo $chosen_workspace

if [ -z "$chosen_workspace" ]; then
  notify-send "Move window canceled" "No workspace selected"
  exit 1
fi

if [ "$chosen_workspace" = "CreateNew" ]; then
    # 弹出输入框让用户输入新workspace的名称
    new_name=$(wofi --dmenu --prompt "Enter new Workspace name")
    if [ -n "$new_name" ]; then
        # 创建并切换到新的special workspace
        hyprctl dispatch movetoworkspace "special:$new_name"
    fi
    exit 1
fi

spaceID=$(echo $chosen_workspace | awk -F'[()]' '{print $2}')

# echo $spaceID

hyprctl dispatch movetoworkspace $spaceID
