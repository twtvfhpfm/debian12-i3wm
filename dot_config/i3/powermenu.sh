#!/bin/bash
ans=$(zenity --info --title "PowerMenu" --text "Choose an action" --ok-label lock --extra-button suspend --extra-button poweroff --extra-button reboot --extra-button expand --extra-button mirror --extra-button single)
rc=$?
case "$rc-$ans" in
	"0-")
		echo "lock"
		i3lock -i ~/.config/i3/lock.png -t
		;;
	"1-suspend")
		echo "suspend"
		systemctl suspend
		;;
	"1-poweroff")
		echo "poweroff"
		systemctl poweroff
		;;
	"1-reboot")
		echo "reboot"
		systemctl reboot
		;;
	"1-expand")
		xrandr --output HDMI-1 --auto --left-of eDP-1
		;;
	"1-mirror")
		xrandr --output HDMI-1 --same-as eDP-1
		;;
	"1-single")
		xrandr --output HDMI-1 --off
		;;
esac

