#!/bin/bash

set -euo pipefail

echo "MAKEOPTS=\"-j1\"" >>/etc/portage/make.conf
echo 'USE="minimal seccomp -doc -examples -test -alsa -jpeg -pipewire -png -pulseaudio -X -wayland -vnc -jack -opengl -vulkan -bluetooth -apparmor -hardened -cuda -selinux -systemd -filecaps -jemalloc -lzo -snappy -nls -pam -sasl -smartcard -udev -oss -dbus -idn -lua"' >>/etc/portage/make.conf

echo "net-libs/gnutls -tools -pkcs11" >>/etc/portage/package.use/gnutls

echo "app-containers/docker -btrfs container-init overlay2" >>/etc/portage/package.use/docker
echo "app-containers/containerd -btrfs cri -device-mapper" >>/etc/portage/package.use/containerd

echo "app-emulation/qemu -accessibility -bpf -capstone -fuse -glusterfs -nfs -rbd -iscsi -multipath -jpeg -png -keyutils -systemtap -debug -test -plugins -sdl -sdl-image -gtk -virgl -vte -spice -wayland -x -usb -usbredir -vde -xattr -xdp -xen -virtfs -ssh" >>/etc/portage/package.use/qemu
echo "QEMU_USER_TARGETS=\"i386 x86_64\"" >>/etc/portage/make.conf
echo "QEMU_SOFTMMU_TARGETS=\"i386 x86_64\"" >>/etc/portage/make.conf

echo "net-dns/dnsmasq -auth-dns -conntrack -dhcp-tools -dnssec -id -libidn2 -loop -nettlehash -script" >>/etc/portage/package.use/dnsmasq
