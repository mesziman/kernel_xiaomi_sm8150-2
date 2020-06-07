#!/bin/bash
git submodule init scripts
git submodule update scripts

KERNEL_DIR=$PWD
ANYKERNEL_DIR=$KERNEL_DIR/AnyKernel3
CCACHEDIR=../CCACHE/cepheus
TOOLCHAINDIR=/pipeline/build/root/toolchain/supergcc
TOOLCHAIN32=/pipeline/build/root/toolchain/supergcc32
DATE=$(date +"%d%m%Y")
KERNEL_NAME="mesziman"
DEVICE="-cepheus-"
VER=$(git rev-parse --short HEAD)
FINAL_ZIP="$KERNEL_NAME""$DEVICE""$VER".zip
corenumber=$( nproc --all )
buildspeed=$(( $corenumber + 2 ))


rm $ANYKERNEL_DIR/Image.gz-dtb
rm $KERNEL_DIR/arch/arm64/boot/Image.gz $KERNEL_DIR/arch/arm64/boot/Image.gz-dtb
export PATH="${TOOLCHAINDIR}/bin:${TOOLCHAIN32}/bin:${PATH}"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${TOOLCHAINDIR}/lib"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${TOOLCHAIN32}/lib"
export ARCH=arm64
export KBUILD_BUILD_USER="mesziman"
export KBUILD_BUILD_HOST="github"
export CROSS_COMPILE=${TOOLCHAINDIR}/bin/aarch64-maestro-linux-gnu-
export CROSS_COMPILE_ARM32=${TOOLCHAIN32}/bin/arm-maestro-linux-gnueabi-
#export CROSS_COMPILE=aarch64-linux-android-
#export CROSS_COMPILE_ARM32=arm-linux-androideabi-
#export LD_LIBRARY_PATH=$TOOLCHAINDIR/lib/
export USE_CCACHE=1
export CCACHE_DIR=$CCACHEDIR/.ccache
echo "===================WHICH========================="
echo "which 32tc $(which ${CROSS_COMPILE_ARM32}ld)"
echo "which $(which ${CROSS_COMPILE_ARM32}gcc)"
echo "ccname noshell build : $(${CC} -v 2>&1 | grep -q "clang version" && echo clang || echo gcc)"
echo "===================WHICH========================="

make clean && make mrproper
make O=out -C $KERNEL_DIR cepheus_defconfig

make -s O=out -C $KERNEL_DIR  -j$buildspeed ARCH=arm64 CROSS_COMPILE=${TOOLCHAINDIR}/bin/aarch64-maestro-linux-gnu- CROSS_COMPILE_ARM32=${TOOLCHAIN32}/bin/arm-maestro-linux-gnueabi- | grep "error:"
{
cp $KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb $ANYKERNEL_DIR/
} || {
if [ $? != 0 ]; then
  echo "FAILED BUILD"
  find $KERNEL_DIR -iname "*dtb"
fi
}
echo "======================VERIFY CLANG==============================="
cat $KERNEL_DIR/out/include/generated/compile.h
echo "======================VERIFY CLANG==============================="
cd $ANYKERNEL_DIR/
zip -r9 $FINAL_ZIP * -x *.zip $FINAL_ZIP
cp $FINAL_ZIP ${WERCKER_REPORT_ARTIFACTS_DIR}/
mv $FINAL_ZIP /pipeline/output/$FINAL_ZIP
