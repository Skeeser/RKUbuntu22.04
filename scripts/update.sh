#!/bin/bash
# 此脚本用来更新img

# 删除旧镜像
echo "delete old img"
rm img/*.img
rm -rf ubuntu_base_rootfs

# 创建空镜像并格式化成ext4文件系统
echo "create new img"
dd if=/dev/zero of=img/ubuntu_rootfs.img bs=1M count=6144
mkfs.ext4 img/ubuntu_rootfs.img

# 挂载并复制
echo "mount and copy"
mkdir ubuntu_base_rootfs
sudo mount img/ubuntu_rootfs.img ubuntu_base_rootfs
sudo cp -rfp ubuntu_rootfs/* ubuntu_base_rootfs/


# 检查镜像并缩小
echo "umount, check, resize img"
sudo umount ubuntu_base_rootfs/
e2fsck -p -f img/ubuntu_rootfs.img
resize2fs -M img/ubuntu_rootfs.img

