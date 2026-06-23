#!/bin/zsh

xsetwacom --list devices
xsetwacom --set "Wacom One by Wacom S Pen stylus" MapToOutput HEAD-0
echo "Wacom One by Wacom S Pen stylus set successful"
xsetwacom --set "Wacom One by Wacom S Pen eraser" MapToOutput HEAD-0
echo "Wacom One by Wacom S Pen eraser set successful"

