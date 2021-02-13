#!/bin/bash
dpkg --add-architecture amd64
apt-get -qq update > /dev/null ;
apt-get -qq install -y  dialog apt-utils > /dev/null ;
apt-get remove -y clang;
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get -qq install -y  gcc-10-aarch64-linux-gnu gcc-10-arm-linux-gnueabi xxd git wget binutils-arm-linux-gnueabi g++-multilib gcc-multilib binutils-aarch64-linux-gnu flex libfl2 libomp-dev python libisl-dev git ccache automake bc lzop bison gperf build-essential zip curl zlib1g-dev libxml2-utils bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev squashfs-tools pngcrush schedtool dpkg-dev liblz4-tool make optipng openssl libssl-dev > /dev/null ;
export LOFASZ=$PWD;

update-alternatives --install /usr/bin/aarch64-linux-gnu-gcc aarch64-linux-gnu-gcc /usr/bin/aarch64-linux-gnu-gcc-10 100 \
    --slave /usr/bin/aarch64-linux-gnu-gcc-ar aarch64-linux-gnu-gcc-ar /usr/bin/aarch64-linux-gnu-gcc-ar-10 \
    --slave /usr/bin/aarch64-linux-gnu-gcc-nm aarch64-linux-gnu-gcc-nm /usr/bin/aarch64-linux-gnu-gcc-nm-10 
    
update-alternatives --install /usr/bin/arm-linux-gnueabi-gcc arm-linux-gnueabi-gcc /usr/bin/arm-linux-gnueabi-gcc-10 100 \
    --slave /usr/bin/arm-linux-gnueabi-gcc-ar arm-linux-gnueabi-gcc-ar /usr/bin/arm-linux-gnueabi-gcc-ar-10 \
    --slave /usr/bin/arm-linux-gnueabi-gcc-nm arm-linux-gnueabi-gcc-nm /usr/bin/arm-linux-gnueabi-gcc-nm-10  
mkdir -p /pipeline/build/root/toolchain/supergcc32;cd /pipeline/build/root/toolchain/supergcc32;
wget -nv https://developer.arm.com/-/media/Files/downloads/gnu-a/10.2-2020.11/binrel/gcc-arm-10.2-2020.11-x86_64-arm-none-eabi.tar.xz
tar xf gcc-arm-10.2-2020.11-x86_64-arm-none-eabi.tar.xz --strip-components 1

mkdir -p /pipeline/build/root/toolchain/supergcc;cd /pipeline/build/root/toolchain/supergcc;
wget -nv https://developer.arm.com/-/media/Files/downloads/gnu-a/10.2-2020.11/binrel/gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz
tar xf gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz --strip-components 1

cd $LOFASZ
bash builder.sh
