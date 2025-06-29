#!/bin/bash

set -euo pipefail

if [[ ! -d "/sources" ]]; then
  echo "error: no sources!"
fi

### dynamips

if [[ ! -d "/sources/dynamips" ]]; then
  echo "error: no dynamips source!"
fi

pushd /sources/dynamips || exit

if [[ -d build ]]; then
  rm -rv build
fi

mkdir -v build
cd build

cmake ..
make
make install

popd || exit

### ubridge

if [[ ! -d "/sources/ubridge" ]]; then
  echo "error: no ubridge source!"
fi

pushd /sources/ubridge || exit

make
make install

popd

### vpcs

if [[ ! -d "/sources/vpcs" ]]; then
  echo "error: no vpcs source!"
fi

pushd /sources/vpcs || exit

cd src
./mk.sh

mv ./vpcs /usr/bin

popd

### libcrypto.so.4 symlink
target="/usr/lib/libcrypto.so.3"

if [[ ! -f "$target" ]]; then
  echo "ERROR!: $target file not found"
  exit 1
fi

arch_info=$(file "$target")

if echo "$arch_info" | grep -q "32-bit"; then
  ln -s /usr/lib/libcrypto.so.3 /usr/lib/libcrypto.so.4
else
  echo "ERROR!: file is not 32bit ELF!"
  echo "$arch_info"
  exit 1
fi

### python
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py --break-system-packages --root-user-action=ignore
pip install platformdirs==4.3.8 --break-system-packages --root-user-action=ignore

PYTHON_TARGET=$(python -c "import site; print(site.getsitepackages()[0])")

pip install -r /requirements.txt \
  --break-system-packages \
  --root-user-action=ignore \
  --target="$PYTHON_TARGET"
