#!/bin/bash

# check if is recording
if pgrep -x "wf-recorder" > /dev/null; then
    pkill -RTMIN+8 waybar
    killall -s SIGINT wf-recorder
    pkill -RTMIN+8 waybar
    notify-send "Recording Finished" "The video is saved"
    exit 0
fi

monitors=$(hyprctl monitors all | grep Monitor | awk '{print $2}')
audio_sources=$(pactl list sources | grep Name | cut -d: -f2- | sed 's/^[[:space:]]*//')

chosen_monitor=$(echo -e "$monitors\nmanual" | wofi --dmenu --prompt "Select Monitor")
if [ -z "$chosen_monitor" ]; then
    notify-send "Recording Cancelled" "No monitor selected"
    exit 1
fi

if [ "$chosen_monitor" == "manual" ]; then
    chosen_monitor="-g $(slurp)"
else
    chosen_monitor="-o $chosen_monitor"
fi

# 选择音频源
chosen_audio=$(echo -e "$audio_sources\nno audio" | wofi --dmenu --prompt "Select Audio")

if [ -z "$chosen_audio" ]; then
    notify-send "Recording Cancelled" "No audio selected"
    exit 1
fi

chosen_format=$(echo -e "mkv\nmp4" | wofi --dmenu --prompt "Choose format")

if [ -z "$chosen_format" ]; then
    notify-send "Format Cancelled" "No format selected"
    exit 1
fi

record_cmd="wf-recorder"

if [ "$chosen_audio" != "no audio" ] && [ -n "$chosen_audio" ]; then
    record_cmd+=" --audio=$chosen_audio"
fi

sleep 2

pkill -RTMIN+8 waybar
cmd="$record_cmd -f "$HOME/Videos/$(date +'%H:%M:%S_%d-%m-%Y').$chosen_format" "$chosen_monitor" &"
$cmd
pkill -RTMIN+8 waybar

# notify-send "Recording Started" "Monitor: $chosen_monitor\nAudio: ${chosen_audio:-no audio}"
