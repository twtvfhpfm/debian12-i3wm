#!/usr/bin/python3

import os
import re
import tkinter as tk
import xml.etree.ElementTree as ET

os.system("lsusb > /tmp/usb.txt")
os.system("lsusb -t > /tmp/usb_tree.txt")
os.system("sudo virsh dumpxml win7 > /tmp/kvm_xml")

class UsbDevice:
    def __init__(self, vid=None, pid=None, bus=0, dev=0):
        self.bus=bus
        self.dev=dev
        self.port=''
        self.vid=vid
        self.pid=pid
        self.model=''
        self.driver=''

    def __eq__(self, other):
        if isinstance(other, UsbDevice):
            return self.bus == other.bus and self.dev == other.dev and self.vid == other.vid and self.pid == other.pid
        return False

    def __str__(self):
        return f"bus {self.bus} dev {self.dev} port {self.port} vid {self.vid} pid {self.pid} driver {self.driver} model {self.model}"

def detach_device(usb_device):
    print(f"detach {usb_device}")
    os.system(f"sudo usb_passthrough.sh detach win7 {usb_device.vid} {usb_device.pid} {usb_device.bus} {usb_device.dev}")

def attach_device(usb_device):
    print(f"attach {usb_device}")
    os.system(f"sudo usb_passthrough.sh attach win7 {usb_device.vid} {usb_device.pid} {usb_device.bus} {usb_device.dev}")

def find_all_usb_devices():
    root = ET.parse("/tmp/kvm_xml")
    device_list = []
# Iterate over all hostdev elements
    for hostdev in root.findall('./devices/hostdev'):
        if hostdev.get("type") != "usb":
            continue
        source = hostdev.find('source')
        vendor_id = source.find('vendor').get('id')
        product_id = source.find('product').get('id')
        address = source.find("address")
        bus = int(address.get("bus"))
        device = int(address.get("device"))
        if vendor_id.startswith("0x"):
            vendor_id = vendor_id[2:]
        if product_id.startswith("0x"):
            product_id = product_id[2:]
        print(f"Vendor ID: {vendor_id}, Product ID: {product_id} bus: {bus} dev: {device}")
        device_list.append(UsbDevice(vendor_id, product_id, bus, device))
    return device_list

def extract_number_after_keyword(text, keyword):
    # 构建正则表达式以匹配关键词后的数字
    pattern = rf"{re.escape(keyword)}\s*(\d+)"
    match = re.search(pattern, text)
    
    if match:
        return int(match.group(1))
    else:
        raise ValueError(f"No integer found after the keyword '{keyword}'.")

def extract_driver(text):
    pattern = rf"{re.escape('Driver=')}(.*?),"
    match = re.search(pattern, text)
    
    if match:
        return match.group(1)
    else:
        raise ValueError(f"No integer found after the keyword Driver=.")


deviceList = []
f=open('/tmp/usb.txt', 'r')
lines = f.readlines()
f.close()
for line in lines:
    items = line.split(" ")
    if items[0] == "Bus" and items[2] == "Device" and items[4] == "ID":
        device = UsbDevice()
        device.bus = int(items[1])
        device.dev = int(items[3][:-1])
        vendor_product = items[5].split(":")
        device.vid = vendor_product[0]
        device.pid = vendor_product[1]
        device.model = " ".join(items[6:])
        deviceList.append(device)

f=open('/tmp/usb_tree.txt', 'r')
lines = f.readlines()
f.close()
port_list = [0, 0, 0, 0]
for line in lines:
    leading_space = len(line) - len(line.lstrip())
    idx = leading_space // 4
    # print(f"idx {idx} line: {line}")
    if idx == 0:
        bus = extract_number_after_keyword(line, 'Bus')
        port_list[idx] = bus
        continue
    port = extract_number_after_keyword(line, 'Port')
    dev = extract_number_after_keyword(line, 'Dev')
    drv = extract_driver(line)
    port_list[idx] = port
    for device in deviceList:
        if device.bus == port_list[0] and device.dev == dev:
            device.port = '.'.join([str(i) for i in port_list[:idx+1]])
            device.driver = drv
            break;

deviceList = [i for i in deviceList if not i.driver.startswith('hub') and len(i.port) > 0]
deviceList.sort(key=lambda dev: dev.port)
for i in deviceList:
    print(str(i))

# 创建主窗口
root = tk.Tk()
root.title("USB redirect")
root.bind("<Escape>", lambda event: root.destroy())

# 用于存储选项的变量
options = [i.port + "\t\t" + i.model for i in deviceList]
checkboxes_vars = []

# 创建复选框并将其显示在窗口中
for i,option in enumerate(options):
    checked = deviceList[i].driver == "usbfs"
    var = tk.BooleanVar(value=checked)
    checkbox = tk.Checkbutton(root, text=option, variable=var)
    checkbox.pack(anchor='w')
    checkboxes_vars.append(var)

def show_selected_options():
    old_devices = find_all_usb_devices()
    for d in old_devices:
        if d not in deviceList:
            detach_device(d)

    # 获取选择结果
    selected = [var.get() for var in checkboxes_vars]
    for i,checked in enumerate(selected):
        if checked and deviceList[i].driver != "usbfs":
            attach_device(deviceList[i])
        elif not checked and deviceList[i].driver == "usbfs":
            detach_device(deviceList[i])
    root.quit()
    # 显示选择结果
    # messagebox.showinfo("Selected Items", f"You selected: {', '.join(selected_items)}")

# 创建按钮以提交选择
submit_button = tk.Button(root, text="确定", command=show_selected_options)
submit_button.pack()

# 开始主事件循环
root.mainloop()
