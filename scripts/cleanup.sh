#!/bin/bash

if [[ -d "/sources" ]]; then
  echo "remove /sources"
  rm -rf /sources
fi

rm -rf /var/tmp/portage
rm -rf /usr/share/doc
rm -rf /usr/share/man
rm -rf /usr/share/info

rm -rf /scripts
