#!/usr/bin/env bash

set -ex

# Download
version=4.5.3
URL="https://codeload.github.com/opencv/opencv/tar.gz/$version"
pushd "${DOWNLOADS}"
wget -N "$URL" -O opencv-$version.tar.gz
popd

# Extract
tar xzf "${DOWNLOADS}/opencv-$version.tar.gz"
mkdir opencv-$version/build-arm

# Determine the architecture
case "${HOST_TRIPLE}" in
    aarch64* ) OPENCV_ENABLE_NEON="ON";  OPENCV_ENABLE_VFPV3="OFF" ;;
    armv8*   ) OPENCV_ENABLE_NEON="ON";  OPENCV_ENABLE_VFPV3="ON"  ;;
    armv7*   ) OPENCV_ENABLE_NEON="ON";  OPENCV_ENABLE_VFPV3="ON"  ;;
    armv6*   ) OPENCV_ENABLE_NEON="OFF"; OPENCV_ENABLE_VFPV3="OFF" ;;
    *        ) echo "Unknown architecture ${HOST_TRIPLE}" && exit 1 ;;
esac

# Configure
. cross-pkg-config
pushd opencv-$version/build-arm
cmake \
    -DCMAKE_TOOLCHAIN_FILE=../platforms/linux/arm.toolchain.cmake \
    -DGNU_MACHINE="${HOST_TRIPLE}" \
    -DCMAKE_SYSTEM_PROCESSOR="${HOST_ARCH}" \
    -DCMAKE_SYSROOT="${RPI_SYSROOT}" \
    -DENABLE_NEON=${OPENCV_ENABLE_NEON} \
    -DENABLE_VFPV3=${OPENCV_ENABLE_VFPV3} \
    -DOPENCV_ENABLE_NONFREE=ON \
    -DWITH_JPEG=OFF -DBUILD_JPEG=OFF \
    -DWITH_PNG=OFF -DBUILD_PNG=OFF \
    -DWITH_TBB=OFF -DBUILD_TBB=OFF \
    -DWITH_FFMPEG=OFF \
    -DWITH_V4L=ON -DWITH_LIBV4L=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="/usr/local" \
    -DOPENCV_GENERATE_PKGCONFIG=ON \
    -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF \
    -DBUILD_OPENCV_PYTHON2=OFF \
    -DBUILD_OPENCV_PYTHON3=OFF \
    -DBUILD_EXAMPLES=OFF \
    .. \
 || { cat CMakeFiles/CMakeError.log && false; }
cat CMakeFiles/CMakeOutput.log

# Build
make -j$(($(nproc) * 2))

# Install
make install DESTDIR="${RPI_SYSROOT}"
make install DESTDIR="${RPI_STAGING}"

# Cleanup
popd
rm -rf opencv-$version

# TODO: check if it's necessary to install NumPy on build
