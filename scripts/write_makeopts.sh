#!/bin/bash

set -euo pipefail

IS_PROD="${IS_PROD:-false}"

if [[ "$IS_PROD" == "true" ]]; then
  MAKEJOBS="1"
else
  MAKEJOBS="$(nproc)"
fi

{
  echo "MAKEOPTS=\"-j$MAKEJOBS\""
} >>/etc/portage/make.conf
