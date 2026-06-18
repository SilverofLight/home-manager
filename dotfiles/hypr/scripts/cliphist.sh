#!/usr/bin/bash

# require: cliphist

# roconf="~/.config/rofi/clipboard.rasi"
# roconf="~/.config/rofi/config.rasi"

# wmenuopt='-l 12 -N "#282B38A3" -n "#F6339A" -M "#424659A3" -m "#F6339A" -S "#424659A3" -s "#F6339A" -f "JetBrains Mono 14"'
case $1 in
    c)  cliphist list | wofi --dmenu --prompt 'Clipboard' | cliphist decode | wl-copy
        # cliphist list | wmenu -b -p 'Clipboard' -l 12 -N "#282B38A3" -n "#F6339A" -M "#424659A3" -m "#F6339A" -S "#424659A3" -s "#F6339A" -f "JetBrains Mono 14" | cliphist decode | wl-copy
        ;; 
    d)  cliphist list | wofi --dmenu  | cliphist delete
        # cliphist list | wmenu -b -l 12 -N "#282B38A3" -n "#F6339A" -M "#424659A3" -m "#F6339A" -S "#424659A3" -s "#F6339A" -f "JetBrains Mono 14" | cliphist delete
        ;;
    w)  if [ echo -e "Yes\nNo" | wofi --dmenu ] ; then
            cliphist wipe
        fi
        ;;
    t)  echo ""
        echo "󰅇 clipboard history"
        ;;
    *)  echo "cliphist.sh [action]"
        echo "c :  cliphist list and copy selected"
        echo "d :  cliphist list and delete selected"
        echo "w :  cliphist wipe database"
        echo "t :  display tooltip"
        ;;
esac

