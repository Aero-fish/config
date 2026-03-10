#!/bin/bash
if [ $# -eq 0 ]; then
    "$HOME"/.local/bin/wine-default-cn.sh 'D:\Myware\7-Zip\7zFM.exe' "."
else
    "$HOME"/.local/bin/wine-default-cn.sh 'D:\Myware\7-Zip\7zFM.exe' "$1"
fi
