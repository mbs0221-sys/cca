#!/bin/bash

# CCA root directory
CCA_ROOT=$(pwd)

NUM_CPUS=4
MAX_RAM=2048

# TF-A binaries directory
TFA_DIR=${CCA_ROOT}/arm-trusted-firmware/build/qemu/release

# UEFI binary
UEFI_BIN=${CCA_ROOT}/u-boot/u-boot.bin

# Build TF-A
pushd arm-trusted-firmware
make CROSS_COMPILE=aarch64-linux-gnu- PLAT=qemu DEBUG=0 BL33=${UEFI_BIN} clean
make CROSS_COMPILE=aarch64-linux-gnu- PLAT=qemu DEBUG=0 BL33=${UEFI_BIN} all fip -j$(nproc)

# Create a 64MB flash image and write BL1, BL2, BL31, and UEFI to it
dd if=build/qemu/release/bl1.bin of=flash.bin bs=4096 conv=notrunc
dd if=build/qemu/release/fip.bin of=flash.bin seek=64 bs=4096 conv=notrunc

popd

# QEMU command with parameters
sudo qemu-system-aarch64 \
 -smp ${NUM_CPUS} \
 -m ${MAX_RAM} \
 -cpu cortex-a57 \
 -M virt,secure=on \
 -nographic \
 -bios arm-trusted-firmware/flash.bin  \
 -drive if=none,file=${CCA_ROOT}/jammy-server-cloudimg-arm64.img,id=hd0 \
 -device virtio-blk-device,drive=hd0 \
 -device virtio-net-device,netdev=net0 \
 -netdev user,id=net0,hostfwd=tcp::2222-:22
