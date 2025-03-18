#!/bin/bash
interface=$1
is_stop=$2
#share_interface="enp0s31f6"
share_interface="wlp4s0"
if [ "$interface" == "" ];then
	echo "param: <interface>"
	exit 1
fi
if [ "$is_stop" == "stop" ];then
	nmcli device set $interface managed yes
else
	nmcli device set $interface managed no
fi
#/sbin/iptables -t nat -D POSTROUTING 1
sleep 1
killall hostapd
sleep 1
#killall dnsmasq
dnsmasq_pid=$(cat /var/run/hostapd_dnsmasq.pid)
kill $dnsmasq_pid
sleep 1
/sbin/iptables -t nat -D POSTROUTING -o $share_interface -j MASQUERADE
/sbin/iptables -D FORWARD -i $share_interface -o $interface -m state --state RELATED,ESTABLISHED -j ACCEPT
/sbin/iptables -D FORWARD -i $interface -o $share_interface -j ACCEPT
if [ "$is_stop" == "stop" ];then
	exit 0
fi

sed "s/interface_name/$interface/g" dnsmasq.conf > /tmp/dnsmasq.conf
sed "s/interface_name/$interface/g" hostapd.conf > /tmp/hostapd.conf
ip addr replace 192.168.233.1/24 dev $interface
/sbin/hostapd -B -d -t -f /tmp/hostapd.log /tmp/hostapd.conf
/sbin/dnsmasq -C /tmp/dnsmasq.conf --pid-file=/var/run/hostapd_dnsmasq.pid
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "add new nat rule"

/sbin/iptables -t nat -A POSTROUTING -o $share_interface -j MASQUERADE
/sbin/iptables -A FORWARD -i $share_interface -o $interface -m state --state RELATED,ESTABLISHED -j ACCEPT
/sbin/iptables -A FORWARD -i $interface -o $share_interface -j ACCEPT

/sbin/iptables -t nat -L POSTROUTING -n -v
/sbin/iptables -L FORWARD -n -v
