## 一. 使用ubuntu-base构建根文件系统

### 1. 到ubuntu官网获取ubuntu-base的压缩包

安装网址:

ubuntu 22.04:  [Ubuntu Base 22.04.3 LTS (Jammy Jellyfish)](https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/)  

其他版本:  [Index of /ubuntu-base/releases](https://cdimage.ubuntu.com/ubuntu-base/releases/)  

在目录下我安装的名称为: [ ubuntu-base-22.04-base-arm64.tar.gz](https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-arm64.tar.gz)



### 2. 将获取到的文件拷贝到ubuntu虚拟机中

新建目录, 解压

命令

```shell
git clone git@github.com:Skeeser/RKUbuntu22.04.git
cd RKUbuntu22.04
mkdir ubuntu_rootfs
sudo tar -xpf source/ubuntu-base-22.04-base-arm64.tar.gz -C ubuntu_rootfs/
```



### 3.  安装qemu-user-static

#### 介绍QEMU

QEMU（Quick EMUlator）是一个开源的虚拟化和仿真工具，它允许在一个平台上运行不同架构的程序。QEMU有一个特殊的模式称为qemu-user-static，它是QEMU的一个组件，用于在一个架构上运行另一个架构的可执行文件，通常用于在主机和目标架构不同的情况下进行交叉编译和测试。

##### 主要功能和用途：

1. **交叉编译**：
   - QEMU用户态模式可以在一个架构上运行另一个架构的可执行文件，这对于交叉编译非常有用。它使得在开发和构建软件时，可以在主机架构上编译运行目标架构的程序。
2. **软件测试和开发**：
   - 对于开发者来说，qemu-user-static是一个方便的工具，可以在主机上运行针对其他架构的软件，这样可以方便地测试和调试。
3. **跨架构兼容性测试**：
   - 运行qemu-user-static可以帮助测试在不同架构之间的可移植性和兼容性，以确保软件在不同平台上的正常运行。



#### 安装

qemu-user-static是一个仿真器，可以选取arm64配置文件仿真开发板运行环境，然后挂载下载的ubuntu-base文件，从而构建ubuntu文件系统。

```shell
sudo apt install qemu-user-static
```

由于下载的ubuntu-base是aarch64架构的，因此需要拷贝qemu-aarch64-static到ubuntu_rootfs/usr/bin/下。

```
sudo cp /usr/bin/qemu-aarch64-static ubuntu_rootfs/usr/bin
```



### 4. 设置软件源

```shell
sudo vim ./ubuntu_rootfs/etc/apt/sources.list
```

替换为

```shell
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy main restricted universe multiverse
# deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy main restricted universe multiverse
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-updates main restricted universe multiverse
# deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-updates main restricted universe multiverse
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-backports main restricted universe multiverse
# deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-backports main restricted universe multiverse

deb http://ports.ubuntu.com/ubuntu-ports/ jammy-security main restricted universe multiverse
# deb-src http://ports.ubuntu.com/ubuntu-ports/ jammy-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-proposed main restricted universe multiverse
# # deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-proposed main restricted universe multiverse
```

要另外的版本的源可以在[ubuntu | 镜像站使用帮助 | 清华大学开源软件镜像站 | Tsinghua Open Source Mirror](https://mirror.tuna.tsinghua.edu.cn/help/ubuntu/)中配置, 但要注意更换的源不要是https的



### 5. 配置DNS

为了可以联网更新软件(在虚拟环境中)，我们拷贝本机的dns配置文件到根文件系统  

```shell
sudo cp /etc/resolv.conf ubuntu_rootfs/etc/resolv.conf
```

然后在/etc/resolv.conf文件中添加dns  

```shell
sudo vim ./ubuntu_rootfs/etc/resolv.conf
```

添加内容如下  

```shell
nameserver 8.8.8.8
nameserver 114.114.114.114
```





### 6. 挂载ubuntu-base文件系统

挂载脚本如下(在/scripts/mount.sh中):

```shell
#!/bin/bash
mnt() {
	echo "MOUNTING"
	sudo mount -t proc /proc ${2}proc
	sudo mount -t sysfs /sys ${2}sys
	sudo mount -o bind /dev ${2}dev
	sudo mount -o bind /dev/pts ${2}dev/pts
	sudo chroot ${2}
}
umnt() {
	echo "UNMOUNTING"
	sudo umount ${2}proc
	sudo umount ${2}sys
	sudo umount ${2}dev/pts
	sudo umount ${2}dev
}
 
if [ "$1" == "-m" ] && [ -n "$2" ] ;
then
	mnt $1 $2
elif [ "$1" == "-u" ] && [ -n "$2" ];
then
	umnt $1 $2
else
	echo ""
	echo "Either 1'st, 2'nd or both parameters were missing"
	echo ""
	echo "1'st parameter can be one of these: -m(mount) OR -u(umount)"
	echo "2'nd parameter is the full path of rootfs directory(with trailing '/')"
	echo ""
	echo "For example: ch-mount -m /media/sdcard/"
	echo ""
	echo 1st parameter : ${1}
	echo 2nd parameter : ${2}
fi
```

> 解释: chroot命令用来改变当前进程的根目录为另一个目录, 但并不是实际的根目录





- 增加脚本执行权限

```shell
sudo chmod +x mount.sh
```

- 挂载文件系统

```shell
bash scripts/mount.sh -m ubuntu_rootfs/
```

- 卸载文件系统

```shell
bash scripts/mount.sh -u ubuntu_rootfs/
```



> 注意：
>
> 挂载后，就进入到了开发板仿真环境，可以安装软件，更改系统配置；
>
> 文件系统构建完成后，输入 exit ，退出仿真环境，然后运行脚本，卸载ubuntu_base文件系统；
>
> 最后，打包镜像。



### 7. 安装必要软件

挂载后  

执行如下  

```shell
apt-get update
```

要注意有没有update成功  

安装软件包  

```shell
apt-get install net-tools
apt-get install ethtool
apt-get install ifupdown
apt-get install psmisc
apt-get install nfs-common
apt-get install htop
apt-get install vim
apt-get install rsyslog
apt-get install iputils-ping
apt-get install language-pack-en-base
apt-get install sudo
apt-get install network-manager
```



### 8. 安装桌面环境

```shell
apt-get install ubuntu-desktop
```





## 常见问题

---

Q: apt更新失败, 出现`No system certificates available. Try installing ca-certificates.`  

A: 看你替换的源是不是https的, 是的话换成http  

---

Q: 照步骤做了, 但还是无法联网安装更新软件  

例如:  

```shell
E: Package 'ifupdown' has no installation candidate
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Package psmisc is not available, but is referred to by another package.
This may mean that the package is missing, has been obsoleted, or
is only available from another source
```

A: 注意apt有没有update  

---

Q: 出现`E: Unable to locate package `找不到包问题  

A:   注意apt有没有update有没有成功  

---

Q: 国内源apt-get update报404的一种可能错误  

A: 更换源的时候有没有换成arm的架构  

---



<br>



## 参考网站

[嵌入式开发板移植ubuntu base系统的方法_lightdm ubuntu-base arm_JiaoCL的博客-CSDN博客](https://blog.csdn.net/liboxiu/article/details/121127635)

[基于ubuntu-base构建根文件系统并移植到RK3568开发板_开发板移植ubuntu-CSDN博客](https://blog.csdn.net/ssismm/article/details/129612239)

[构建Ubuntu20.04根文件系统并移植到RK3568_ubuntu文件系统-CSDN博客](https://blog.csdn.net/weixin_46025014/article/details/131682463)

