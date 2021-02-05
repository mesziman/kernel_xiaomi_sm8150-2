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
DEVICE="-cepheus-R11-TESTBUILD-"
VER=$(git rev-parse --short HEAD)
FINAL_ZIP="$KERNEL_NAME""$DEVICE""$VER".zip
corenumber=$( nproc --all )
buildspeed=$(( $corenumber + 2 ))


rm $ANYKERNEL_DIR/Image.gz-dtb
rm $KERNEL_DIR/arch/arm64/boot/Image.gz $KERNEL_DIR/arch/arm64/boot/Image.gz-dtb
export ARCH=arm64
export KBUILD_BUILD_USER="mesziman"
export KBUILD_BUILD_HOST="github"

export PATH="${TOOLCHAINDIR}/bin:${TOOLCHAIN32}/bin:${PATH}"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${TOOLCHAINDIR}/lib"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${TOOLCHAIN32}/lib"

make clean && make mrproper
make O=out -C $KERNEL_DIR cepheus_defconfig
make -s O=out -C $KERNEL_DIR  -j$buildspeed ARCH=arm64 CROSS_COMPILE=aarch64-none-elf- CROSS_COMPILE_ARM32=arm-none-eabi- 2>&1 | tee ${WERCKER_REPORT_ARTIFACTS_DIR}/errorlog.txt
{
cp $KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb $ANYKERNEL_DIR/
} || {
if [ $? != 0 ]; then
  echo "FAILED BUILD"
  exit
fi
}
echo "======================VERIFY CLANG==============================="
cat $KERNEL_DIR/out/include/generated/compile.h
echo "======================VERIFY CLANG==============================="
cd $ANYKERNEL_DIR/
zip -r9 $FINAL_ZIP * -x *.zip $FINAL_ZIP
cp $FINAL_ZIP ${WERCKER_REPORT_ARTIFACTS_DIR}/
curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d text="New build $(cat $KERNEL_DIR/changelog.txt)" -d chat_id=@meszimankernel ;
curl -F chat_id="-1001477254593" -F document=@"$FINAL_ZIP" https://api.telegram.org/bot$BOT_API_KEY/sendDocument
mv $FINAL_ZIP /pipeline/output/$FINAL_ZIP
