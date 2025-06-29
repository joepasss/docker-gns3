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

### openssl

ARCH=$(uname -m)

case "$ARCH" in
  x86_64)
    sed -i '/^PORTAGE_BINHOST/d' /etc/portage/make.conf
    sed -i 's/\bgetbinpkg\b/-getbinpkg/' /etc/portage/make.conf
    USE="abi_x86_32" emerge -vq dev-libs/openssl

    ;;

  arm64 | aarch64)
    wget https://github.com/openssl/openssl/releases/download/openssl-3.5.0/openssl-3.5.0.tar.gz -O /sources/openssl-3.5.0.tar.gz
    tar xpvf /sources/openssl-3.5.0.tar.gz

    pushd /sources/openssl-3.5.0 || exit

    export CC="gcc -m32"
    export CFLAGS="-m32"
    export LDFLAGS="-m32"

    ./Configure linux-generic32 \
      --prefix=/usr \
      --openssldir=/etc/ssl \
      --libdir=lib32 \
      shared \
      zlib-dynamic

    make
    make install_sw

    popd || exit
    ;;

  *) ;;
esac

readarray -t targets < <(find /usr/lib* -name libcrypto.so.3 2>/dev/null)
found=0

for target in "${targets[@]}"; do
  arch_info=$(file "$target")

  if echo "$arch_info" | grep -q "32-bit"; then
    ln -sf "$target" "/usr/lib/libcrypto.so.4"
    found=1
    break
  fi
done

if [[ "$found" -eq 0 ]]; then
  echo "ERROR!: cannot find libcrytpo.so.3"
  exit 1
fi

unset targets
unset found
unset target_path
unset arch_info

unset ARCH

### python

wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py --break-system-packages --root-user-action=ignore
pip install platformdirs==4.3.8 --break-system-packages --root-user-action=ignore

PYTHON_TARGET=$(python -c "import site; print(site.getsitepackages()[0])")

pip install -r /requirements.txt \
  --break-system-packages \
  --root-user-action=ignore \
  --target="$PYTHON_TARGET"

unset PYTHON_TARGET
