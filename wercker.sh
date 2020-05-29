#!/bin/bash


dpkg --add-architecture amd64 && apt-get -qq update && apt-get -qq install -y git libfl2 libomp-dev binutils-arm-linux-gnueabi g++-multilib gcc-multilib binutils-aarch64-linux-gnu git ccache automake bc lzop bison gperf build-essential zip curl zlib1g-dev  g++-multilib  libxml2-utils bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev squashfs-tools pngcrush schedtool dpkg-dev liblz4-tool make optipng &&
export LOFASZ=$PWD && 
git clone --depth=1 https://github.com/arter97/arm64-gcc /pipeline/build/root/toolchain/supergcc
git clone --depth=1 https://github.com/arter97/arm32-gcc /pipeline/build/root/toolchain/supergcc32
cd $LOFASZ
bash builder.sh
