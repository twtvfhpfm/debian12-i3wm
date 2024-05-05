#!/bin/bash
ans=$(zenity --info --title "PowerMenu" --text "Choose an action" --ok-label lock --extra-button suspend --extra-button poweroff --extra-button reboot)
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
esac

