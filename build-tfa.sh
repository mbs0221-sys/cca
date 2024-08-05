#!/bin/bash

pushd arm-trusted-firmware

# debug
# make CROSS_COMPILE=aarch64-linux-gnu- PLAT=qemu all DEBUG=1
# release
# make CROSS_COMPILE=aarch64-linux-gnu- PLAT=qemu all
make PLAT=qemu BL33=../u-boot/u-boot.bin all fip DEBUG=1 LOG_LEVEL=50
popd