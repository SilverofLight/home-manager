#!/bin/bash

# author: Silver Lee
# date: 2024/12/9
# description: weather reporter with dnust, default city is wuhan, also can use other cities
# requirements: network, dnust

# Default city is Wuhan, but can be overridden by command line argument
CITY=${1:-"Jiayuguan"}

# Check if it's Wuhan and local weather file exists
if [ "$CITY" = "Jiayuguan" ] && [ -f "$HOME/Templates/weather" ]; then
    weather=$(cat "$HOME/Templates/weather")
else
    # Get weather information (added &m for metric units - Celsius)
    weather=$(curl -s "wttr.in/$CITY?format=Location:%l\nTemp:%t\nWeather:%c&m" 2>/dev/null)
fi

# Debug output
# echo "Debug: Weather info: $weather"

if [ -n "$weather" ] && [ $? -eq 0 ]; then
    # Send notification
    notify-send "Weather Report" "$weather" -i weather-few-clouds -u normal
else
    # Send error notification if failed
    notify-send "Weather Error" "Please check your network connection or city name" -i weather-severe-alert
fi
