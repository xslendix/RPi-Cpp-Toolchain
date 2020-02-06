#!/usr/bin/env bash

set -ex

# Download
git clone -b 'v1.8.2' --single-branch --depth 1 \
    https://chromium.googlesource.com/webm/libvpx

# Configure
pushd libvpx
. cross-pkg-config
CROSS="${HOST_TRIPLE}-" \
./configure \
    --enable-install-srcs \
    --disable-install-docs \
    --enable-shared \
    --target="armv8-linux-gcc" \
    --prefix="/usr/local" \
    --extra-cflags="--sysroot=${RPI3_SYSROOT}" \
    --extra-cxxflags="--sysroot=${RPI3_SYSROOT}"

# Build
make -j$(($(nproc) * 2))

# Install
make install DESTDIR="${RPI3_SYSROOT}"
make install DESTDIR="${RPI3_STAGING}"

# Cleanup
popd
rm -rf libvpx