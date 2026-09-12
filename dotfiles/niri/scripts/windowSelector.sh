#!/bin/bash

clients=$(hyprctl clients | awk -v RS= '{
  title = ""
  pid = ""

  # 提取标题 (第一行 -> 后面的内容)
  if ($0 ~ /->/) {
      match($0, /->[^:]*/)
      title = substr($0, RSTART+2, RLENGTH-2)
  }

  # 提取 PID
  if ($0 ~ /pid:/) {
      match($0, /pid:[ \t]*[0-9]+/)
      pid_str = substr($0, RSTART, RLENGTH)
      split(pid_str, arr, /[ \t:]+/)
      pid = arr[length(arr)]  # 取最后一个元素确保获取纯数字PID
  }

  if (title != "" && pid != "") {
      print title " | " pid
  }
}')

selected_client=$(echo -e "$clients" | wofi --dmenu --prompt "clients")

if [ -z "$selected_client" ]; then
    exit 1
fi

pid=$(echo "$selected_client" | cut -d'|' -f2 | tr -d ' ')
hyprctl dispatch focuswindow pid:$pid
