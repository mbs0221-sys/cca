#!/bin/bash

pushd linux-5.15.115

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
make defconfig
make -j16

popd