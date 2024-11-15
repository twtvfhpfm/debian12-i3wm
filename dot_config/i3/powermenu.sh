#!/bin/bash
ans=$(zenity --info --title "PowerMenu" --text "Choose an action" --ok-label suspend --extra-button expand --extra-button single --extra-button mirror --extra-button poweroff --extra-button reboot)
rc=$?
case "$rc-$ans" in
	"0-")
		echo "suspend"
		systemctl suspend
		;;
	"1-expand")
		xrandr --output HDMI-1 --auto --left-of eDP-1
		;;
	"1-single")
		xrandr --output HDMI-1 --off
		;;
	"1-mirror")
		xrandr --output HDMI-1 --auto --same-as eDP-1
		;;
	"1-poweroff")
		echo "poweroff"
		systemctl poweroff
		;;
	"1-reboot")
		echo "reboot"
		systemctl reboot
		;;
	"1-scale")
		echo "scale"
		xrandr --output HDMI-1 --scale 0.5x0.5
		;;
esac

