#!/bin/bash

# CCA root directory
CCA_ROOT=$(pwd)

NUM_CPUS=8
MAX_RAM=4096

CPU_FEATURES="pmu=on,sve=on,sve128=on,sve256=on,neon=on"
CPU="${CPU},$CPU_FEATURES"

# TF-A binaries directory
TFA_DIR=${CCA_ROOT}/arm-trusted-firmware/build/qemu/release

# QEMU command with parameters
sudo qemu-system-aarch64 \
    -smp ${NUM_CPUS} \
    -m ${MAX_RAM} \
    -cpu cortex-a57 \
    -M virt,secure=on,mte=off \
    -nographic \
    -bios arm-trusted-firmware/flash.bin  \
    -drive if=none,file=${CCA_ROOT}/jammy-server-cloudimg-arm64.img,id=hd0 \
    -device virtio-blk-device,drive=cloud \
    -drive if=none,id=cloud,file=cloud.img,format=raw \
    -device virtio-blk-device,drive=hd0 \
    -virtfs local,path=/home/bsmei,mount_tag=host0,security_model=mapped,id=host0 \
    -object rng-random,filename=/dev/urandom,id=rng0 \
    -device virtio-rng-pci,rng=rng0,max-bytes=1024,period=1000 \
    -device virtio-net-device,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::2222-:22
