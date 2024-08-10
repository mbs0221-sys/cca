#!/bin/bash

# 检查输入参数
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <rootfs.tar.xz> <output.qcow2>"
    exit 1
fi

ROOTFS_TAR=$1
QCOW2_FILE=$2
MOUNT_POINT="/rootfs"
DISK_SIZE="10G"

cd /data || exit

# 创建 qcow2 文件
echo "Creating qcow2 file..."
qemu-img create -f qcow2 "$QCOW2_FILE" $DISK_SIZE
if [ $? -ne 0 ]; then
    echo "Failed to create qcow2 file."
    exit 1
fi

# 连接 qcow2 文件到 /dev/nbd0
echo "Connecting qcow2 file..."
modprobe nbd max_part=8
if [ $? -ne 0 ]; then
    echo "Failed to load nbd module."
    exit 1
fi

qemu-nbd --connect=/dev/nbd0 "$QCOW2_FILE"
if [ $? -ne 0 ]; then
    echo "Failed to connect qcow2 file to /dev/nbd0."
    exit 1
fi

# 创建分区并格式化为 ext4 文件系统
echo "Partitioning and formatting..."
echo -e "n\np\n1\n\n\nw" | fdisk /dev/nbd0
if [ $? -ne 0 ]; then
    echo "Failed to create partition."
    exit 1
fi

# 确认分区已创建
sleep 2  # 等待分区表更新
if [ ! -e /dev/nbd0p1 ]; then
    echo "/dev/nbd0p1 does not exist. Exiting."
    exit 1
fi

mkfs.ext4 /dev/nbd0p1
if [ $? -ne 0 ]; then
    echo "Failed to format partition."
    exit 1
fi

# 创建挂载点并挂载分区
echo "Mounting the partition..."
mkdir -p $MOUNT_POINT
mount /dev/nbd0p1 $MOUNT_POINT
if [ $? -ne 0 ]; then
    echo "Failed to mount partition."
    exit 1
fi

# 解压 rootfs.tar.xz 到挂载点
echo "Extracting rootfs..."
tar -xf "$ROOTFS_TAR" -C $MOUNT_POINT
if [ $? -ne 0 ]; then
    echo "Failed to extract rootfs."
    exit 1
fi

# 卸载分区并断开 nbd 设备
echo "Cleaning up..."
umount $MOUNT_POINT
if [ $? -ne 0 ]; then
    echo "Failed to unmount partition."
    exit 1
fi

qemu-nbd --disconnect /dev/nbd0
if [ $? -ne 0 ]; then
    echo "Failed to disconnect nbd device."
    exit 1
fi

# 清理挂载点
rmdir $MOUNT_POINT
if [ $? -ne 0 ]; then
    echo "Failed to remove mount point."
    exit 1
fi

echo "Done. Created $QCOW2_FILE."
