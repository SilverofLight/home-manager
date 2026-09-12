#!/bin/bash

# check if is recording
if pgrep -x "wf-recorder" > /dev/null; then
    pkill -RTMIN+8 waybar
    killall -s SIGINT wf-recorder
    pkill -RTMIN+8 waybar
    pactl unload-module module-loopback
    pactl unload-module module-null-sink
    pkill -RTMIN+8 waybar
    notify-send "Recording Finished" "The video is saved"
    exit 0
fi

monitors=$(hyprctl monitors all | grep Monitor | awk '{print $2}')
# audio_sources=$(pactl list sources | grep Name | cut -d: -f2 | sed 's/^[[:space:]]*//')

chosen_monitor=$(echo -e "$monitors\nmanual" | rofi -dmenu -i -mesg "Select Monitor")
if [ -z "$chosen_monitor" ]; then
    notify-send "Recording Cancelled" "No monitor selected"
    exit 1
fi

if [ "$chosen_monitor" == "manual" ]; then
    chosen_monitor="-g $(slurp)"
else
    chosen_monitor="-o $chosen_monitor"
fi

output_audios=$(pactl list sources | grep "output" | grep Name | awk '{print $2}')
chosen_output=$(echo -e "No output\n$output_audios" | rofi -dmenu -i -mesg "Select output audio")

if [ -z "$chosen_output" ]; then
    notify-send "Output Cancelled" "No output selected"
    exit 1
fi

input_audios=$(pactl list sources | grep "input" | grep Name | awk '{print $2}')
chosen_input=$(echo -e "No input\n$input_audios" | rofi -dmenu -i -mesg "Select input")

if [ -z "$chosen_input" ]; then
    notify-send "Input Cancelled" "No input selected"
    exit 1
fi

if [ "$chosen_output" == "No output" ]; then
    if [ "$chosen_input" == "No input" ]; then
        chosen_audio=""
    else
        chosen_audio="$chosen_input"
    fi
else
    if [ "$chosen_input" == "No input" ]; then
        chosen_audio="$chosen_output"
    else
        pactl load-module module-null-sink sink_name=Combined
        pactl load-module module-loopback sink=Combined source=$chosen_output
        pactl load-module module-loopback sink=Combined source=$chosen_input
        sleep 1
        chosen_audio="Combined.monitor"
    fi
fi

chosen_format=$(echo -e "mkv\nmp4" | rofi -dmenu -i -mesg "Choose format")

if [ -z "chosen_format" ]; then
    notify-send "Format Cancelled" "No format selected"
    exit 1
fi

record_cmd="wf-recorder"

if [ -n "$chosen_audio" ]; then
    record_cmd+=" --audio=$chosen_audio"
fi

sleep 2

pkill -RTMIN+8 waybar
$record_cmd -f "$HOME/Videos/$(date +'%H:%M:%S_%d-%m-%Y').$chosen_format" "$chosen_monitor" &
pkill -RTMIN+8 waybar

# notify-send "Recording Started" "Monitor: $chosen_monitor\nAudio: ${chosen_audio:-no audio}"
