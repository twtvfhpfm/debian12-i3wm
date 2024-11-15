#!/bin/bash
LOGFILE=/tmp/fixmouse.log
MOUSE="HUAWEI Mouse CD26 SE Mouse"
TOUCHPAD="SynPS/2 Synaptics TouchPad"
date >> $LOGFILE
echo "execute cmd: $1" >> $LOGFILE
export DISPLAY=:0
export XAUTHORITY=/home/xu/.Xauthority
xinput --set-prop "$MOUSE" "Coordinate Transformation Matrix" 0.3 0 0 0 0.3 0 0 0 1 >> $LOGFILE 2>&1
xinput --set-prop "$MOUSE" "libinput Accel Speed" 1 >> $LOGFILE 2>&1
echo "execute done" >> $LOGFILE

xinput set-prop "$TOUCHPAD" "Coordinate Transformation Matrix" 0.6 0 0 0 0.6 0 0 0 1.0
xinput set-prop "$TOUCHPAD" "Synaptics Move Speed" 1 5 0.035 0
xinput set-prop "$TOUCHPAD" "Synaptics Scrolling Distance" -500 -800
