#!/bin/bash

# sudo apt install libgnutls28-dev

pushd u-boot

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-

make qemu_arm64_defconfig
make -j16

popd