#!/bin/bash

CPU=max
NUM_CPUS=16
MAX_RAM=8192

CPU_FEATURES="pmu=off,sve=on,sve128=on,sve256=on,neon=on"
CPU="${CPU},$CPU_FEATURES"

sudo qemu-system-aarch64 \
 -smp ${NUM_CPUS} \
 -m ${MAX_RAM} \
 -cpu ${CPU} \
 -M virt \
 -nographic \
 -drive if=pflash,format=raw,file=efi.img,readonly=on \
 -drive if=pflash,format=raw,file=varstore.img \
 -drive if=none,file=jammy-server-cloudimg-arm64.img,id=hd0 \
 -drive file=user-data.img,format=raw \
 -device virtio-blk-device,drive=hd0 \
 -netdev type=tap,id=net0 \
 -device virtio-net-device,netdev=net0 \
 -netdev user,id=net1,hostfwd=tcp::2222-:22 \
 -device virtio-net-device,netdev=net1 \
 -netdev tap,id=net2,ifname=tap0,script=no,downscript=no \
 -device virtio-net-device,netdev=net2