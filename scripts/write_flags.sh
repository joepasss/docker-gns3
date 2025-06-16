#!/bin/bash

set -euo pipefail

{
  echo 'MAKEOPTS="-j1"'
  echo 'USE="minimal seccomp -doc -examples -test -alsa -jpeg -pipewire -pulseaudio -jack -X -wayland -vnc -opengl -vulkan -cuda -bluetooth -apparmor -hardened -selinux -systemd -filecaps -jemalloc -lzo -snappy -nls -pam -sasl -smartcard -udev -oss -dbus -idn -lua"'
  echo 'QEMU_USER_TARGETS="i386 x86_64"'
  echo 'QEMU_SOFTMMU_TARGETS="i386 x86_64"'
} >>/etc/portage/make.conf
