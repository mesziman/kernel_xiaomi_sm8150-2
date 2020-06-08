#!/bin/bash
dpkg --add-architecture amd64
apt-get -qq update > /dev/null ;
apt-get -qq install -y  dialog apt-utils > /dev/null ;
apt-get remove -y clang;
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get -qq install -y  xxd git flex libfl2 libomp-dev python libisl-dev git ccache automake bc lzop bison gperf build-essential zip curl zlib1g-dev libxml2-utils bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev squashfs-tools pngcrush schedtool dpkg-dev liblz4-tool make optipng openssl libssl-dev > /dev/null ;
export LOFASZ=$PWD;

git clone --depth=1 https://github.com/arter97/arm64-gcc /pipeline/build/root/toolchain/supergcc;
git clone --depth=1 https://github.com/arter97/arm32-gcc /pipeline/build/root/toolchain/supergcc32;

cd $LOFASZ
bash builder.sh
