#!/bin/bash

# CCA root directory
CCA_ROOT=$(pwd)
HOME_DIR="${HOME}"

NUM_CPUS=8
MAX_RAM=4096

CPU_FEATURES="pmu=on,sve=on,sve128=on,sve256=on,neon=on"
CPU="${CPU},$CPU_FEATURES"

# QEMU command with parameters
sudo qemu-system-aarch64 \
    -smp ${NUM_CPUS} \
    -m ${MAX_RAM} \
    -cpu cortex-a57 \
    -M virt,secure=on,mte=off \
    -nographic \
    -bios arm-trusted-firmware/flash.bin \
    -kernel linux/arch/arm64/boot/Image \
    -append 'console=ttyAMA0,38400 keep_bootcon root=/dev/vda1 rw' \
    -drive format=qcow2,if=none,file=rootfs.qcow2,id=hd0 \
    -device virtio-blk-device,drive=hd0 \
    -virtfs local,path="${HOME_DIR}",mount_tag=host0,security_model=mapped,id=host0 \
    -object rng-random,filename=/dev/urandom,id=rng0 \
    -device virtio-rng-pci,rng=rng0,max-bytes=1024,period=1000 \
    -device virtio-net-device,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::2221-:22 \
    -serial mon:stdio \
    -d unimp,guest_errors \
    -no-acpi