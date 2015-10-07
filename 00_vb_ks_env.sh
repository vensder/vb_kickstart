#!/bin/bash

mkdir -p ~/.config/VirtualBox/TFTP/{pxelinux.cfg,images/centos/7}

wget -O - https://www.kernel.org/pub/linux/utils/boot/syslinux/6.xx/syslinux-6.03.tar.gz | \
tar -xzf - -C ~/.config/VirtualBox/TFTP/ --transform='s/.*\///' \
syslinux-6.03/bios/{core/pxelinux.0,com32/{menu/{menu,vesamenu}.c32,libutil/libutil.c32,elflink/ldlinux/ldlinux.c32,chain/chain.c32,lib/libcom32.c32}}

cd ~/.config/VirtualBox/TFTP/images/centos/7/
wget http://mirror.yandex.ru/centos/7/os/x86_64/images/pxeboot/{initrd.img,vmlinuz}

cat <<END > ~/.config/VirtualBox/TFTP/pxelinux.cfg/01-08-00-27-86-ce-3e
PROMPT 0
NOESCAPE 0
ALLOWOPTIONS 0
TIMEOUT 600

DEFAULT centos7

LABEL centos7
  KERNEL images/centos/7/vmlinuz
  APPEND initrd=images/centos/7/initrd.img ks=http://192.168.122.1/kickstart/centos7-ks.cfg ip=dhcp ksdevice=eth0 ramdisk_size=10000 ipv6.disable=1 biosdevnames=0 net.ifnames=0 unsupported_hardware text
END

mkdir -p ~/http/kickstart
cat <<END > ~/http/kickstart/centos7-ks.cfg
install
lang en_GB.UTF-8
keyboard us
timezone --utc US/Central
auth --useshadow --enablemd5
selinux --disabled
firewall --disabled
services --enabled=NetworkManager,sshd
eula --agreed
ignoredisk --only-use=sda
reboot

bootloader --location=mbr
zerombr
clearpart --all --initlabel
part swap --asprimary --fstype="swap" --size=1024
part /boot --fstype xfs --size=200
part pv.01 --size=1 --grow
volgroup rootvg01 pv.01
logvol / --fstype xfs --name=lv01 --vgname=rootvg01 --size=1 --grow

rootpw "test12345"

repo --name=base --baseurl=http://mirror.yandex.ru/centos/7/os/x86_64/
url --url="http://mirror.yandex.ru/centos/7/os/x86_64/"

%packages --nobase --ignoremissing
@core
%end
END


cp ~/.config/VirtualBox/TFTP/pxelinux.0 ~/.config/VirtualBox/TFTP/centos7.pxe


