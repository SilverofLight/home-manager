#!/bin/bash

# author: Silver Lee
# date: 2024/12/1
# description: use rofi to select a wallpaper in WALLPAPER_DIR, choose a random transition to display, Or use awww.sh daemon to change wallpaper every 20min
# requirements: awww

# 壁纸存放目录
WALLPAPER_DIR="$HOME/Pictures/wallpaper"

# 确保 awww daemon 正在运行
if ! pgrep -x "awww-daemon" > /dev/null; then
    awww init
fi

# 切换壁纸的函数
change_wallpaper() {
    if [ -n "$1" ]; then
        # 如果提供了具体路径，直接使用该路径
        WALLPAPER="$1"
        if [ ! -f "$WALLPAPER" ]; then
            echo "错误：找不到指定的壁纸文件"
            exit 1
        fi
    else
        # 随机选择一张图片
        WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) | shuf -n 1)
    fi
    
    # 定义可用的过渡效果数组
    TRANSITIONS=("simple" "wipe" "grow" "center" "outer" "wave" "random" "any")
    # 随机选择一个过渡效果
    RANDOM_TRANSITION=${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}
    
    # 随机生成过渡位置
    POSITIONS=("top" "center" "bottom" "left" "right")
    RANDOM_POSITION=${POSITIONS[$RANDOM % ${#POSITIONS[@]}]}
    
    # 随机生成过渡持续时间（1-3秒）
    RANDOM_DURATION=$((RANDOM % 3 + 1))
    
    # 使用随机效果设置壁纸
    awww img "$WALLPAPER" \
        --transition-fps 60 \
        --transition-type "$RANDOM_TRANSITION" \
        --transition-pos "$RANDOM_POSITION" \
        --transition-duration "$RANDOM_DURATION"
}

# 根据脚本运行方式执行不同操作
if [[ $1 == "daemon" ]]; then
    # 作为后台程序运行，每隔一段时间更换壁纸
    while true; do
        change_wallpaper
        sleep 1200
    done
elif [[ -n "$1" && "$1" != "daemon" ]]; then
    # 如果提供了文件路径参数，使用指定的壁纸
    change_wallpaper "$1"
else
    # 直接运行则只随机更换一次壁纸
    change_wallpaper
fi
