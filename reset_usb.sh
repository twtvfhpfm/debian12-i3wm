#!/bin/bash
cd /sys/bus/pci/drivers/xhci_hcd
ls
BUS="0000:00:14.0"
echo "$BUS" > unbind
sleep 5
echo "$BUS" > bind
sleep 5
find "$BUS/" -name control -exec /bin/sh -c "echo on > {}" \;
