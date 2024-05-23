#!/bin/bash
/sbin/iptables -t nat -D POSTROUTING 1
sleep 1
killall hostapd
sleep 1
killall dnsmasq
sleep 1
/sbin/hostapd -B hostapd.conf
/sbin/dnsmasq -C dnsmasq.conf
echo 1 > /proc/sys/net/ipv4/ip_forward
/sbin/iptables -t nat -A POSTROUTING -o wlp3s0 -j MASQUERADE

