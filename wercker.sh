#!/bin/bash
dpkg --add-architecture amd64
apt-get -qq update > /dev/null ;
apt-get -qq install -y  dialog apt-utils > /dev/null ;
apt-get remove -y clang;
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get -qq install -y xxd git binutils-arm-linux-gnueabi g++-multilib gcc-multilib binutils-aarch64-linux-gnu flex libfl2 libomp-dev python libisl-dev git ccache automake bc lzop bison gperf build-essential zip curl zlib1g-dev libxml2-utils bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev squashfs-tools pngcrush schedtool dpkg-dev liblz4-tool make optipng openssl libssl-dev > /dev/null ;
export LOFASZ=$PWD;

git clone --depth=1 https://github.com/P-404/proprietary_vendor_qcom_sdclang /pipeline/build/root/toolchain/sdclang; 
git clone --depth=1 https://github.com/arter97/arm32-gcc /pipeline/build/root/toolchain/supergcc32;
git clone --depth=1 https://github.com/arter97/arm64-gcc /pipeline/build/root/toolchain/supergcc64;

ln -s /usr/lib/x86_64-linux-gnu/libncurses.so.6 /usr/lib/libncurses.so.5;
ln -s /usr/lib/x86_64-linux-gnu/libtinfo.so.6 /usr/lib/libtinfo.so.5;
cd $LOFASZ
bash builder.sh
