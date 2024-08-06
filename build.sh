#!/bin/bash

# CCA root directory
CCA_ROOT=$(pwd)

# UEFI binary
UEFI_BIN=${CCA_ROOT}/u-boot/u-boot.bin

sudo apt install libgnutls28-dev

# Build kernel
pushd linux-5.15.115
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
make defconfig
make -j16
popd

# Build u-boot
pushd u-boot
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
make qemu_arm64_defconfig
make -j16
popd

# Build EDK2
pushd edk2
git submodule update --init
make -C BaseTools
source edksetup.sh
export GCC5_AARCH64_PREFIX=aarch64-linux-gnu-
build -a AARCH64 -t GCC5 -p ArmVirtPkg/ArmVirtQemuKernel.dsc -b RELEASE
popd

# Build TF-A
pushd arm-trusted-firmware
make CROSS_COMPILE=aarch64-linux-gnu- PLAT=qemu DEBUG=0 BL33=${UEFI_BIN} clean
make CROSS_COMPILE=aarch64-linux-gnu- PLAT=qemu DEBUG=0 BL33=${UEFI_BIN} all fip -j$(nproc)
# Create a 64MB flash image and write BL1, BL2, BL31, and EFI(u-boot) to it
dd if=build/qemu/release/bl1.bin of=flash.bin bs=4096 conv=notrunc
dd if=build/qemu/release/fip.bin of=flash.bin seek=64 bs=4096 conv=notrunc
popd

# Build buildroot
test -f buildroot-2024.05.tar.xz || wget https://buildroot.org/downloads/buildroot-2024.05.tar.xz
test -d buildroot-2024.05 || tar xf buildroot-2024.05.tar.xz
pushd buildroot-2024.05
make qemu_arm64_virt_defconfig
utils/config -e BR2_TARGET_ROOTFS_CPIO
utils/config -e BR2_TARGET_ROOTFS_CPIO_GZIP
make olddefconfig
make -j$(nproc)
popd