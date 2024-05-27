#!/bin/bash
nmcli device set wlxbc307eab1114 managed no
#/sbin/iptables -t nat -D POSTROUTING 1
sleep 1
killall hostapd
sleep 1
killall dnsmasq
sleep 1
/sbin/hostapd -B hostapd.conf
/sbin/dnsmasq -C dnsmasq.conf
ip addr replace 192.168.233.1/24 dev wlxbc307eab1114
echo 1 > /proc/sys/net/ipv4/ip_forward
/sbin/iptables -t nat -L -n
if [ "$1" == "nat" ];then
	echo "add new nat rule"
	/sbin/iptables -t nat -A POSTROUTING -o enp0s31f6 -j MASQUERADE
	/sbin/iptables -A FORWARD -i enp0s31f6 -o wlxbc307eab1114 -m state --state RELATED,ESTABLISHED -j ACCEPT
	/sbin/iptables -A FORWARD -i wlxbc307eab1114 -o enp0s31f6 -j ACCEPT
fi

