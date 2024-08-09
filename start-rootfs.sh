#!/bin/bash

qemu-system-aarch64 -nographic \
    -machine virt,secure=on \
    -cpu cortex-a57 \
    -kernel buildroot/output/images/Image \
    -append 'console=ttyAMA0,38400 keep_bootcon' \
    -initrd buildroot/output/images/rootfs.cpio.gz \
    -smp 2 \
    -m 1024 \
    -bios arm-trusted-firmware/flash.bin \
    -d unimp \
    -no-acpi
