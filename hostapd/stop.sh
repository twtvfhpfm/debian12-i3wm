#!/bin/bash
interface=$1
nmcli device set $interface managed yes
killall hostapd
killall dnsmasq
iptables -F
iptables -t nat -F
