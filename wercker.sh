#!/bin/bash
dpkg --add-architecture amd64
apt-get -qq update > /dev/null ;
apt-get -qq install -y  dialog apt-utils > /dev/null ;
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get -qq install -y  xxd git flex libfl2 libomp-dev binutils-arm-linux-gnueabi g++-multilib gcc-multilib binutils-aarch64-linux-gnu python libisl-dev git ccache automake bc lzop bison gperf build-essential zip curl zlib1g-dev  g++-multilib  libxml2-utils bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev squashfs-tools pngcrush schedtool dpkg-dev liblz4-tool make optipng > /dev/null ;
export LOFASZ=$PWD;
git clone --depth=1 https://github.com/TheHitMan7/aarch64-maestro-linux-android  /pipeline/build/root/toolchain/supergcc;
git clone --depth=1 https://github.com/TheHitMan7/arm-maestro-linux-gnueabi /pipeline/build/root/toolchain/supergcc32;
cd $LOFASZ
bash builder.sh
