#!/bin/bash

ln -s arm-trusted-firmware/build/qemu/release/bl1.bin bl1.bin
ln -s arm-trusted-firmware/build/qemu/release/bl2.bin bl2.bin
ln -s arm-trusted-firmware/build/qemu/release/bl31.bin bl31.bin
ln -s edk2/Build/ArmVirtQemuKernel-AARCH64/RELEASE_GCC5/FV/QEMU_EFI.fd bl33.bin
ln -s linux/arch/arm64/boot/Image Image