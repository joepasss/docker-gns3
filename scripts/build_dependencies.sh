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

### python
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py --break-system-packages --root-user-action=ignore
pip install platformdirs==4.3.8 --break-system-packages --root-user-action=ignore

PYTHON_TARGET=$(python -c "import site; print(site.getsitepackages()[0])")

pip install -r /requirements.txt \
  --break-system-packages \
  --root-user-action=ignore \
  --target="$PYTHON_TARGET"
