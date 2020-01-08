#!/bin/bash

apt_update() {
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" dist-upgrade
}
