#!/bin/bash
dpkg --add-architecture amd64
apt-get -qq update > /dev/null ;
apt-get -qq install -y  dialog apt-utils > /dev/null ;
apt-get remove -y clang;
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get -qq install -y  xxd git  binutils-arm-linux-gnueabi g++-multilib gcc-multilib binutils-aarch64-linux-gnu flex libfl2 libomp-dev python libisl-dev git ccache automake bc lzop bison gperf build-essential zip curl zlib1g-dev libxml2-utils bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev squashfs-tools pngcrush schedtool dpkg-dev liblz4-tool make optipng openssl libssl-dev > /dev/null ;
export LOFASZ=$PWD;

# git clone --depth=1 https://github.com/mvaisakh/gcc-arm64 /pipeline/build/root/toolchain/supergcc;
# git clone --depth=1 https://github.com/mvaisakh/gcc-arm /pipeline/build/root/toolchain/supergcc32;

mkdir -p /pipeline/build/root/toolchain/supergcc32;cd /pipeline/build/root/toolchain/supergcc32;
wget https://developer.arm.com/-/media/Files/downloads/gnu-a/10.2-2020.11/binrel/gcc-arm-10.2-2020.11-x86_64-arm-none-eabi.tar.xz
tar xf gcc-arm-10.2-2020.11-x86_64-arm-none-eabi.tar.xz --strip-components 1

mkdir -p /pipeline/build/root/toolchain/supergcc;cd /pipeline/build/root/toolchain/supergcc;
wget https://developer.arm.com/-/media/Files/downloads/gnu-a/10.2-2020.11/binrel/gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz
tar xf gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz --strip-components 1

cd $LOFASZ
bash builder.sh
