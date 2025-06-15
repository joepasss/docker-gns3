#!/bin/bash

set -euo pipefail

echo "MAKEOPTS=\"-j$(nproc)\"" >>/etc/portage/make.conf
echo "USE=\"minimal -doc -examples -test -alsa -jpeg -pipewire -png -pulseaudio -X -wayland -vnc -jack -opengl -vulkan -bluetooth\"" >>/etc/portage/make.conf

echo "net-dns/dnsmasq script" >>/etc/portage/package.use/dnsmasq
echo "net-libs/gnutls tools pkcs11" >>/etc/portage/package.use/gnutls
