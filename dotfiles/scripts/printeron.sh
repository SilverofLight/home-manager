#!/bin/zsh

# > printer:
sudo systemctl start avahi-daemon.service avahi-daemon.socket avahi-dnsconfd.service  
sudo systemctl start cups  
# lpr \<filename\>
# sudo systemctl enable avahi-daemon.service avahi-daemon.socket avahi-dnsconfd.service  
# sudo systemctl enable cups  
