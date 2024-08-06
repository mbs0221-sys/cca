# qemu

## Introduction

This repository contains the scripts and configurations to run a QEMU virtual machine with an ARM64 architecture.

## Installation

### Dependencies

```bash
# Download the QEMU_EFI image, extract and gunzip it
$ wget https://releases.linaro.org/components/kernel/uefi-linaro/16.02/release/qemu64/QEMU_EFI.img.gz
$ tar -xvf QEMU_EFI.img.gz
$ gunzip QEMU_EFI.img.gz
# Download the linux kernel and extract it
$ wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.115.tar.xz
$ tar -xvf linux-5.15.115.tar.xz
```

### ARM Trusted Firmware

```bash
# Download the ARM Trusted Firmware and compile it with the QEMU_EFI image
$ cd ~/cca/arm-trusted-firmware
$ make CROSS_COMPILE=aarch64-linux-gnu- PLAT=qemu all fip DEBUG=0 BL33=~/cca/QEMU_EFI.fd
```

### cloud images

```bash
# Create a new image with 32G of space and 64M for the varstore and efi
$ qemu-img create -f qcow2 ubuntu-arm64.qcow2 32G
$ truncate -s 64m varstore.img
$ truncate -s 64m efi.img
$ dd if=/usr/share/qemu-efi-aarch64/QEMU_EFI.fd of=efi.img conv=notrunc
# Download the image from the cloud images
$ axel -n 10 https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-arm64.img
# Resize the image to 32G
$ dd if=/dev/zero of=flash0.img bs=1M count=64
```

```bash
# Install the cloud-image-utils
sudo apt-get install cloud-image-utils
# Create a user-data file
cat >user-data <<EOF
#cloud-config
password: asdfqwer
chpasswd: { expire: False }
ssh_pwauth: True
EOF
# Set the user-data to the image
cloud-localds user-data.img user-data
```

```bash
$ sudo apt install guestfs-tools
# Resize
$ qemu-img resize jammy-server-cloudimg-arm64.img 20GB
# Change the root password
$ sudo virt-customize -a jammy-server-cloudimg-arm64.img --root-password password:coolpass
[   0.0] Examining the guest ...
[  18.8] Setting a random seed
virt-customize: warning: random seed could not be set for this type of 
guest
[  18.9] Setting the machine ID in /etc/machine-id
[  18.9] Setting passwords
[  20.8] SELinux relabelling
[  20.9] Finishing off
# Change the ubuntu user password
$ sudo virt-customize -a jammy-server-cloudimg-arm64.img --password ubuntu:password:coolpass
[   0.0] Examining the guest ...
[  13.7] Setting a random seed
[  13.8] Setting passwords
[  15.6] SELinux relabelling
[  15.6] Finishing off
# Remove the cloud-init package
$ sudo virt-customize -a jammy-server-cloudimg-arm64.img --uninstall cloud-init
[   0.0] Examining the guest ...
[  18.8] Setting a random seed
[  18.9] Running: apt-get remove -y cloud-init
# Show the image information
$ qemu-img info jammy-server-cloudimg-arm64.img 
image: jammy-server-cloudimg-arm64.img
file format: qcow2
virtual size: 20 GiB (21474836480 bytes)
disk size: 598 MiB
cluster_size: 65536
Format specific information:
    compat: 0.10
    compression type: zlib
    refcount bits: 16
Child node '/file':
    filename: jammy-server-cloudimg-arm64.img
    protocol type: file
    file length: 598 MiB (626720768 bytes)
    disk size: 598 MiB
```

## References

[Using Cloud Images With KVM](https://serverascode.com/2018/06/26/using-cloud-images.html)

[qemu 对 ARMv8的支持](https://blog.csdn.net/u011011827/article/details/123843917)

[qemu: boot aarch64, with ATF(arm trusted firmware) and EDK2 firmware](https://www.linkedin.com/pulse/qemu-boot-aarch64-atfarm-trusted-firmware-edk2-nikos-mouzakitis/)
