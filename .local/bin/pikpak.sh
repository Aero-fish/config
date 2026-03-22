#!/bin/bash
if [ -f "$HOME/.wine/net/drive_c/Program Files (x86)/PikPak/PikPak.exe" ]; then
    "$HOME/.local/bin/wine-net.sh" 'C:\Program Files (x86)\PikPak\PikPak.exe'

elif [ -f "$HOME/.wine/net/drive_c/Program Files/PikPak/PikPak.exe" ]; then
    "$HOME/.local/bin/wine-net.sh" 'C:\Program Files\PikPak\PikPak.exe'

else
    notify-send "Cannot find PikPak.exe"
fi
