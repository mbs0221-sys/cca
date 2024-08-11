#!/bin/bash

NUM_CPUS=16
MAX_RAM=8192

CPU_FEATURES="pmu=off,sve=on,sve128=on,sve256=on,neon=on"
CPU="${CPU},$CPU_FEATURES"

sudo qemu-system-aarch64 \
    -smp ${NUM_CPUS} -m ${MAX_RAM} -M virt \
    -nographic \
    -d unimp \
    -bios bl1.bin \
    -drive if=none,file=jammy-server-cloudimg-arm64.img,id=hd0 \
    -drive file=user-data.img,format=raw \
    -device virtio-blk-device,drive=hd0 \
    -netdev user,id=net1,hostfwd=tcp::2222-:22 \
    -device virtio-net-device,netdev=net1 \
    -virtfs local,path=/home/bsmei,mount_tag=host0,security_model=mapped,id=host0 \
    -cpu cortex-a57