#!/bin/bash

# author: Silver Lee
# date: 2024/12/8
# description: Check if my kernel is up to date
# requirements: dunst

# 获取当前运行的内核版本
RUNNING_KERNEL=$(uname -r)

# 获取已安装的最新内核版本（使用pacman）
LATEST_KERNEL=$(pacman -Q linux-cachyos | awk '{print $2}')

# 规范化版本号（将点号替换为横杠）
LATEST_KERNEL=${LATEST_KERNEL//.arch/-arch}

# 比较版本
if [ "$RUNNING_KERNEL" = "$LATEST_KERNEL" ]; then
    # 如果版本相同，发送正在运行最新版本的通知
    dunstify "Kernel Status" "Kernel is up to date" -u low
    echo "Kernel is up to date"
else
    # 如果版本不同，发送需要重启的通知
    dunstify "Kernel Status" "New kernel version detected!\nRunning: $RUNNING_KERNEL\nLatest: $LATEST_KERNEL\nPlease consider rebooting" -u critical
    echo -e "New kernel version detected!\nRunning: $RUNNING_KERNEL\nLatest: $LATEST_KERNEL\nPlease consider rebooting"
fi
