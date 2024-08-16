#!/bin/bash
interface=$1
nat=$2
share_interface="enp0s31f6"
if [ "$interface" == "" ];then
	echo "param: <interface>"
	exit 1
fi
nmcli device set $interface managed no
#/sbin/iptables -t nat -D POSTROUTING 1
sleep 1
killall hostapd
sleep 1
killall dnsmasq
sleep 1
sed "s/interface_name/$interface/g" dnsmasq.conf > /tmp/dnsmasq.conf
sed "s/interface_name/$interface/g" hostapd.conf > /tmp/hostapd.conf
/sbin/hostapd -B -d -t -f /tmp/hostapd.log /tmp/hostapd.conf
/sbin/dnsmasq -C /tmp/dnsmasq.conf
ip addr replace 192.168.233.1/24 dev $interface
echo 1 > /proc/sys/net/ipv4/ip_forward
if [ "$nat" == "nat" ];then
	echo "add new nat rule"
	/sbin/iptables -t nat -A POSTROUTING -o $share_interface -j MASQUERADE
	/sbin/iptables -A FORWARD -i $share_interface -o $interface -m state --state RELATED,ESTABLISHED -j ACCEPT
	/sbin/iptables -A FORWARD -i $interface -o $share_interface -j ACCEPT
fi
/sbin/iptables -t nat -L POSTROUTING -n -v
/sbin/iptables -L FORWARD -n -v
