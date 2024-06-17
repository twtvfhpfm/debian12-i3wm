#!/bin/bash
if [ "$1" == "" ];then
	echo "usage: <wifi_dev> <channel>"
	exit -1
fi
DEV=$1
CHANNEL=$2
nmcli device set $DEV managed no
ifconfig $DEV down
iw dev $DEV set monitor none
ifconfig $DEV up
iw dev $DEV set channel $CHANNEL HT40-
