#!/bin/bash

# CCA root directory
CCA_ROOT=$(pwd)

NUM_CPUS=16
MAX_RAM=8192

# TF-A binaries directory
TFA_DIR=${CCA_ROOT}/arm-trusted-firmware/build/qemu/release

# UEFI binary
UEFI_BIN=${CCA_ROOT}/QEMU_EFI.fd

# Build TF-A
# pushd arm-trusted-firmware
# make CROSS_COMPILE=aarch64-linux-gnu- PLAT=qemu DEBUG=0 BL33=~/cca/QEMU_EFI.fd clean
# make CROSS_COMPILE=aarch64-linux-gnu- PLAT=qemu DEBUG=0 BL33=~/cca/QEMU_EFI.fd all fip -j$(nproc)
# popd

# Create a 64MB flash image and write BL1, BL2, BL31, and UEFI to it
FLASH_IMG=${CCA_ROOT}/flash.img
dd if=/dev/zero of=${FLASH_IMG} bs=1M count=64
dd if=${TFA_DIR}/bl1.bin of=${FLASH_IMG} conv=notrunc
dd if=${TFA_DIR}/fip.bin of=${FLASH_IMG} bs=4096 conv=notrunc

# QEMU command with parameters
sudo qemu-system-aarch64 \
 -smp ${NUM_CPUS} \
 -m ${MAX_RAM} \
 -cpu cortex-a57 \
 -M virt \
 -nographic \
 -bios ${FLASH_IMG} \
 -drive if=none,file=${CCA_ROOT}/jammy-server-cloudimg-arm64.img,id=hd0 \
 -device virtio-blk-device,drive=hd0 \
 -device virtio-net-device,netdev=net0 \
 -netdev user,id=net0,hostfwd=tcp::2222-:22