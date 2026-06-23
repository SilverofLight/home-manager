#!/bin/bash

echo -e "\033[94mWelcome to kd!\033[0m"

HISTORY_FILE=~/Templates/kd_history
touch $HISTORY_FILE
history -c
history -r $HISTORY_FILE

while true; do
  # Ctrl+D 退出
  if ! read -r -e -p "> " msg; then
    echo -e "exit"
    exit 0
  fi

  # 首先检查是否以 -l 开头, 完整模式
  if [[ "$msg" =~ ^-l ]]; then
    cmd="${msg#-l}" # 移除开头的 -l
    cmd="${cmd## }" # 移除开头的空格
    echo $cmd >> $HISTORY_FILE
    history -r $HISTORY_FILE
    if [ -n "$cmd" ]; then
      kd "$cmd"
    fi
    continue
  fi

  if [ "$msg" = "clear" ] || [ "$msg" = "c" ]; then
    clear
    echo -e "\033[94mWelcome to kd!\033[0m"
    continue
  fi

  # 默认为简洁模式
  if [ -n "$msg" ]; then
    echo $msg >> $HISTORY_FILE
    history -r $HISTORY_FILE
    base_output=$(kd "$msg" | sed -e 's#    \[#\n    [#g' -e '/⸺⸺⸺⸺⸺/q')
    echo "$base_output" | sed '1,2d;$d' | wl-copy
    # 第一行为红色，第二行如果是注音，则为绿色，倒数第二行为红色
    echo "$base_output" |
      awk 'NR==1 {print "\033[31m" $0 "\033[0m"; next} 
               NR==2 {print; next} 
               {prev=line; line=$0; lines[NR]=$0} 
               END {
                   if (NR > 1) {lines[NR-1]="\033[31m" prev "\033[0m"}
                   for (i=3; i<NR; i++) print "  " lines[i]
                   if (NR >= 1) print line
               }' |
      sed -e 's#\[\([^\]]*\)\]#\x1b[92m[\1]\x1b[0m#g'
  fi
done
