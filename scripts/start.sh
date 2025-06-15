#!/bin/bash

PYTHON_PATH=$(python -c "import site; print(site.getsitepackages()[0])")
GNS_BIN="$PYTHON_PATH/bin/gns3server"

if [ ! -x "$GNS_BIN" ]; then
  echo "error: gns3server not found!"
  exit 1
fi

if [ "${CONFIG}x" == "x" ]; then
  CONFIG=/data/config.ini
fi

if [ ! -e "$CONFIG" ]; then
  cp /config.ini /data
fi

brctl addbr virbr0
ip link set dev virbr0 up
if [ "${BRIDGE_ADDRESS}x" == "x" ]; then
  BRIDGE_ADDRESS=172.21.1.1/24
fi
ip ad add "${BRIDGE_ADDRESS}" dev virbr0
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

dnsmasq -i virbr0 -z -h --dhcp-range=172.21.1.10,172.21.1.250,4h
dockerd --storage-driver=vfs --data-root=/data/docker/ &
$GNS_BIN -A --config "$CONFIG"
