#!/bin/bash
set -e

# Define the NDK path and other variables
NDK_PATH=$ANDROID_HOME/ndk/21.4.7075529
TOOLCHAIN=$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64
TARGET=aarch64-linux-android
MIN_SDK_VERSION=21

# Export cross compiler and sysroot
export CC=$TOOLCHAIN/bin/$TARGET$MIN_SDK_VERSION-clang
export CXX=$TOOLCHAIN/bin/$TARGET$MIN_SDK_VERSION-clang++
export SYSROOT=$TOOLCHAIN/sysroot

# Create a directory for building libunwind
mkdir -p /tmp/libunwind
cd /tmp/libunwind

# Download libunwind source
git clone https://github.com/llvm/llvm-project.git
cd llvm-project
git checkout release/10.x

# Configure and build libunwind
cmake -B build -S libunwind \
  -DCMAKE_TOOLCHAIN_FILE=$NDK_PATH/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-$MIN_SDK_VERSION \
  -DANDROID_STL=c++_static \
  -DLIBUNWIND_ENABLE_SHARED=OFF \
  -DCMAKE_INSTALL_PREFIX=/tmp/libunwind-install

cmake --build build --target install

# The built libunwind library will be available in /tmp/libunwind-install