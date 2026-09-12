#!/bin/bash

current_name=$(hyprctl activewindow | grep 'workspace' | awk '{print $3}' | sed -n 's/.*(\(.*\))/\1/p' | sed 's/^special://')
current_id=$(hyprctl activewindow | grep "workspace" | awk '{print $2}')

if [ $current_id -le 0 ]; then
    hyprctl dispatch togglespecialworkspace $current_name
    exit 0
fi

# 获取现有的special workspaces
workspaces=$(hyprctl workspaces | grep special | awk '{print $4}' | sed -n 's/.*(\(.*\))/\1/p')

# 添加"新建"选项到列表开头
options="CreateNew\n$workspaces"

# 显示wofi菜单
selected=$(echo -e "$options" | wofi --dmenu --prompt "Select Special Workspace")

if [ -n "$selected" ]; then
    if [ "$selected" = "CreateNew" ]; then
        # 弹出输入框让用户输入新workspace的名称
        new_name=$(wofi --dmenu --prompt "Enter new Special Workspace name")
        if [ -n "$new_name" ]; then
            # 创建并切换到新的special workspace
            hyprctl dispatch workspace "special:$new_name"
        fi
    else
        # 切换到选中的已有workspace
        hyprctl dispatch workspace "$selected"
    fi
fi
