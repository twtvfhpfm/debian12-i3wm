#!/bin/bash

action=$1
vm_name=$2
vendor_id=$3
product_id=$4
bus=$5
device=$6

if [ x"$vm_name" == x ] || [ x"$vendor_id" == x ] || [ x"$product_id" == x ] || [ x"$bus" == x ] || [ x"$device" == x ] || [ x"$action" == x ];then
    echo "param error"
    exit -1
fi
# 构建USB设备的XML配置
usb_xml="<hostdev mode='subsystem' type='usb' managed='yes'>
  <source>
    <vendor id='0x$vendor_id'/>
    <product id='0x$product_id'/>
    <address bus='$bus' device='$device'/>
  </source>
</hostdev>"

# 创建临时文件保存XML配置
temp_usb_xml=$(mktemp)
echo "$usb_xml" > "$temp_usb_xml"

# 直通USB设备到选定的虚拟机
if [ $action == "attach" ];then
    virsh attach-device "$vm_name" "$temp_usb_xml" --current
else
    virsh detach-device "$vm_name" "$temp_usb_xml" --current
fi

# 清理临时文件
rm -f "$temp_usb_xml"
