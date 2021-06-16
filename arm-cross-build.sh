#!/bin/bash

set -v

# clean up old container (if exists)
lxc stop rpi-cross
lxc delete rpi-cross
rm -rf ./cross-build-files/

# launch new container
lxc launch ubuntu:x rpi-cross

# install needed packages
lxc exec rpi-cross -- apt update
lxc exec rpi-cross -- apt upgrade -y --fix-missing
lxc exec rpi-cross -- apt autoremove -y
lxc exec rpi-cross -- apt update
lxc exec rpi-cross -- apt install -y gcc-5-arm-linux-gnueabihf build-essential make cmake unzip tree

# push source files to container
make distclean
zip -r sourcesfiles.zip ../cFS/
lxc file push sourcesfiles.zip rpi-cross/root/
lxc exec rpi-cross -- unzip sourcesfiles.zip

# compile
lxc exec rpi-cross -- ./cFS/cross-build.sh
lxc file pull -r rpi-cross/root/cFS/build cross-build-files

# cleanup
lxc stop rpi-cross
lxc delete rpi-cross
