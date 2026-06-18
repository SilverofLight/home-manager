#!/bin/bash

prev_lyric=""
while true; do
    # 获取当前歌曲信息
    song_name=$(mpc current --format "%title%" 2>/dev/null)
    if [[ -z "$song_name" ]]; then
        # echo "You are not playing a song"
        sleep 1
        continue
    fi

    # 定位歌词文件
    lyrics_file="$HOME/Music/lyrics/${song_name}.lrc"
    if [[ ! -f "$lyrics_file" ]]; then
        echo "lyrics file not found"
        sleep 1
        continue
    fi

    # 获取并转换播放时间
    current_time_str=$(mpc status | awk 'NR==2 {print $3}' | cut -d'/' -f1)
    [[ -z "$current_time_str" ]] && { sleep 1; continue; }
    
    IFS=':' read -r minutes seconds <<< "$current_time_str"
    current_time=$((10#$minutes * 60 + 10#$seconds))
    # echo "current_time: $current_time"

    # 解析歌词并去重
    current_lyric=$(awk -v ct="$current_time" '
    BEGIN {
        max_time = -1
        current_lyric = ""
    }
    {
        clean_lyric = $0
        gsub(/\[.*\]/, "", clean_lyric)
        gsub(/^[ \t]+|[ \t]+$/, "", clean_lyric)

        line = $0
        while (match(line, /\[([0-9]+):([0-9]+)\.?([0-9]*)\]/, m)) {
          # t = m[1] * 60 + m[2] + 1 - (m[3] ? (100 - m[3])/100 : 0)
          t = m[1] * 60 + m[2]
            
            if (t <= ct && t > max_time) {
                max_time = t
                current_lyric = clean_lyric
            }
            
            line = substr(line, RSTART + RLENGTH)
        }
    }
    END {
        if (max_time != -1 && current_lyric != "") {
            print current_lyric
        } else {
            # print "Could not found current lyric"
        }
    }' "$lyrics_file")
    # echo "current lyric: $current_lyric"

    if [[ "$current_lyric" != "$prev_lyric" ]] && [[ -n "$current_lyric" ]]; then
        echo "$current_lyric"
        prev_lyric="$current_lyric"
    fi
    
    sleep 0.1
done
