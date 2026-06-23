#!/bin/bash

# author: Silver Lee
# date: 2024/12/16
# description: download weather info and save to Templates folder
# requirements: network, curl

# Default city is Wuhan, but can be overridden by command line argument
CITY=${1:-"Jiayuguan"}

# Create Templates directory if it doesn't exist
mkdir -p "$HOME/Templates"

# Get weather information (added &m for metric units - Celsius)
weather=$(curl -s "wttr.in/$CITY?format=Location:%l\nTemp:%t\nWeather:%c&m" 2>/dev/null)

if [ -n "$weather" ] && [ $? -eq 0 ]; then
    # Save weather info to file
    echo "$weather" > "$HOME/Templates/weather"
    echo "Weather information saved to $HOME/Templates/weather"
else
    echo "Error: Failed to get weather information. Please check your network connection or city name."
fi 
