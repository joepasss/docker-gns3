#!/bin/bash

set -euo pipefail

# in prod, change to MAKEOPTS=-j1 (or 2)
{
  #  echo "MAKEOPTS=\"-j$(nproc)\""
  echo 'MAKEOPTS="-j2"'

  echo 'USE="minimal seccomp -doc -nls -man -perl -pam -acl -xattr -dbus -udev -systemd -readline -gpm -bash-completion -examples -test -alsa -pipewire -pulseaudio -jack -X -wayland -vnc -opengl -vulkan -cuda -bluetooth -apparmor -hardened -selinux -filecaps -jemalloc -lzo -snappy -sasl -smartcard -oss -idn -lua -gui -openmp -lzma -debug -jpeg"'

  echo 'QEMU_USER_TARGETS="i386 x86_64"'
  echo 'QEMU_SOFTMMU_TARGETS="i386 x86_64"'

  echo 'FEATURES="-test -sandbox nodoc noinfo noman"'
  echo 'INSTALL_MASK="/usr/share/man /usr/share/doc /usr/share/info /usr/share/gtk-doc /usr/share/locale /usr/lib/locale"'

  echo 'INPUT_DEVICES=""'
  echo 'VIDEO_CARDS=""'
  echo 'ACCEPT_LICENSE="*"'
} >>/etc/portage/make.conf
