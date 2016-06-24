#!/bin/bash

apt_update() {
unset UCF_FORCE_CONFFOLD
export UCF_FORCE_CONFFNEW=YES
ucf --purge /boot/grub/menu.lst
export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get update
sudo -E apt-get -o Dpkg::Options::="--force-confold" --force-yes -fuy dist-upgrade
}
