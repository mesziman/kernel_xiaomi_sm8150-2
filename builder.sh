#!/bin/bash

KERNEL_DIR=$PWD
ANYKERNEL_DIR=$KERNEL_DIR/AnyKernel2
CCACHEDIR=../CCACHE/cepheus
TOOLCHAINDIR=/pipeline/build/root/toolchain/supergcc
TOOLCHAIN32=/pipeline/build/root/toolchain/supergcc32
DATE=$(date +"%d%m%Y")
KERNEL_NAME="KernelZ"
DEVICE="-cepheus"
VER="-GCC9-"
FINAL_ZIP="$KERNEL_NAME""$DEVICE""$VER""$DATE".zip

export PATH="${TOOLCHAINDIR}/bin:${TOOLCHAIN32}/bin:${PATH}"
export LD_LIBRARY_PATH="${TOOLCHAINDIR}/lib/gcc/aarch64-elf/9.2.0:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${TOOLCHAIN32}/lib/gcc/arm-eabi/9.2.0:$LD_LIBRARY_PATH"
export ARCH=arm64
export KBUILD_BUILD_USER="mesziman"
export KBUILD_BUILD_HOST="github"
export CROSS_COMPILE=aarch64-elf-
export CROSS_COMPILE_ARM32=arm-eabi-
export USE_CCACHE=1
export CCACHE_DIR=$CCACHEDIR/.ccache
echo "===================WHICH========================="
echo "which 32tc $(which ${CROSS_COMPILE_ARM32}ld))"
echo "which ${CROSS_COMPILE_ARM32}gcc"
echo "realpath of 32tc $(realpath $(dir $(which ${CROSS_COMPILE_ARM32}ld))/..)"
echo "ccnamekbuild : $(shell ${CC} -v 2>&1 | grep -q "clang version" && echo clang || echo gcc && echo $$ && echo $0)"

echo "ccname noshell build : $(${CC} -v 2>&1 | grep -q "clang version" && echo clang || echo gcc)"
echo "===================WHICH========================="
NOW=$( date +"%Y-%m-%d-%H-%M"  )
make clean && make mrproper
make O=out -C $KERNEL_DIR cepheus_defconfig
make O=out -C $KERNEL_DIR  -j$( nproc --all ) ARCH=arm64 CROSS_COMPILE=aarch64-elf- CROSS_COMPILE_ARM32=arm-eabi-  2>&1 | tee -a ${WERCKER_REPORT_ARTIFACTS_DIR}/log_${NOW}.log

{
cp $KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb $ANYKERNEL_DIR/capricorn
} || {
if [ $? != 0 ]; then
  echo "FAILED BUILD"
fi
}
echo "======================VERIFY CLANG==============================="
cat $KERNEL_DIR/out/include/generated/compile.h
echo "======================VERIFY CLANG==============================="
echo "======================VERIFY DTB  ==============================="
echo $(find out/arch/arm64/boot/dts/** -type f -name "*dtb" | sort)
echo "======================VERIFY DTB  ==============================="
grep "error:" ${WERCKER_REPORT_ARTIFACTS_DIR}/log_${NOW}.log >> ${WERCKER_REPORT_ARTIFACTS_DIR}/log_errors.log
