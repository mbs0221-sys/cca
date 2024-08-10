#!/bin/bash

    # -initrd buildroot/output/images/rootfs.cpio \
sudo qemu-system-aarch64 -nographic \
    -cpu cortex-a57 \
    -M virt,secure=on,mte=off \
    -kernel linux/arch/arm64/boot/Image \
    -append 'console=ttyAMA0,38400 keep_bootcon root=/dev/vda1 rw' \
    -drive format=qcow2,if=none,file=rootfs.qcow2,id=hd0 \
    -device virtio-blk-device,drive=hd0 \
    -smp 2 \
    -m 1024 \
    -bios arm-trusted-firmware/flash.bin \
    -object rng-random,filename=/dev/urandom,id=rng0 \
    -device virtio-rng-pci,rng=rng0,max-bytes=1024,period=1000 \
    -device virtio-net-device,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::2221-:22 \
    -serial mon:stdio \
    -d unimp,guest_errors \
    -no-acpi