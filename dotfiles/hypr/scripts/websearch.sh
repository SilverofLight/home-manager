#!/bin/bash

# author: Silver Lee
# date: 2025/5/15
# description: use wofi to search in web, then store the search history
# requirements: wofi, brave, sqlite3

DB_FILE="$HOME/Templates/searchHistory.db"

if [ ! -f "$DB_FILE" ]; then
    notify-send "初始化数据库..."
    sqlite3 "$DB_FILE" <<EOF
CREATE TABLE data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOF
fi

db_content=$(sqlite3 $DB_FILE "SELECT content FROM data ORDER BY created_at DESC;")

db_content=$(sqlite3 "$DB_FILE" "SELECT content FROM data ORDER BY created_at DESC;")
if [ -z "$db_content" ]; then
    text="delete"
else
    text="${db_content}\ndelete"
fi

text=$(echo -e "$text" | wofi --conf $HOME/.config/wofi/config_search --dmenu --prompt "search history")

# command="env GTK_IM_MODULE=fcitx,QT_IM_MODULE=fcitx,XMODIFIERS=@im=fcitx /opt/zen-browser-bin/zen-bin"
command="qutebrowser"
# command=$browser

if [ -z $text ]; then
  exit 1
fi

if [ $text == "delete" ]; then
  rm $DB_FILE
  exit 1
fi

# 检测记录是否已存在
EXISTS=$(sqlite3 "$DB_FILE" "SELECT 1 FROM data WHERE content = '$text' LIMIT 1;")

if [ -n "$EXISTS" ]; then
    sqlite3 "$DB_FILE" "DELETE FROM data WHERE content = '$text';"
fi

# 插入新数据
sqlite3 "$DB_FILE" "INSERT INTO data (content) VALUES ('$text');"

# sqlite3 $DB_FILE "SELECT content FROM data ORDER BY created_at DESC;"

if [[ $text == "d "* ]]; then # duckduckgo
  prompt=$(echo "$text" | cut -d' ' -f2- | sed -E 's/ +/+/g')
  $command https://duckduckgo.com/?q=$prompt&ia=web
elif [[ $text == "b "* ]]; then # bilibili
  prompt=$(echo "$text" | cut -d' ' -f2- | sed -E 's/ +/+/g')
  $command https://search.bilibili.com/all?keyword=$prompt
elif [[ $text == "g "* ]]; then # github
  prompt=$(echo "$text" | cut -d' ' -f2- | sed -E 's/ +/+/g')
  $command https://github.com/search?q=$prompt&type=repositories
else                           # default duckduckgo
  prompt=$(echo "$text" | sed -E 's/ +/+/g')
  $command https://duckduckgo.com/?q=$prompt&ia=web
fi

